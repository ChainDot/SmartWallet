// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "./Ownable.sol";

contract Testament is Ownable {
    using Address for address payable;

    mapping(address => uint256) _beneficiaryBalance;
    address private _doctor;
    bool private _isDead;

    event withdrewHeritage(address indexed beneficiary, uint256 amount);
    event bequeathed(address indexed recipient, uint256 amount);
    event doctorSwapped(address indexed doctor);
    event dead(bool isdead);

    constructor(address owner_, address doctor_) Ownable(owner_) {
        _doctor = doctor_;
    }

    modifier onlyDoctor() {
        require(
            msg.sender == _doctor,
            "Testament: You can not call this function you are not the doctor"
        );
        _;
    }

    // the doctor can pronounce the person dead only once
    function pronouncedDead() public onlyDoctor {
        _isDead = true;
        emit dead(_isDead);
    }

    function withdrawHeritage() public {
        require(_isDead == true, "Testament: The person is not dead yet");
        require(
            _beneficiaryBalance[msg.sender] > 0,
            "Testament : can not withdraw 0 ether"
        );
        uint256 amount = _beneficiaryBalance[msg.sender];
        _beneficiaryBalance[msg.sender] = 0;
        payable(msg.sender).sendValue(amount);
        emit withdrewHeritage(msg.sender, amount);
    }

    function bequeath(address account, uint256 amount)
        public
        payable
        onlyOwner
    {
        require(
            msg.value == amount,
            "Testament: value should be equal to amount"
        );
        require(account != address(0), "Testament: transfer to zero address");
        require(
            _isDead != true,
            "Testament: the owner is dead you can not bequeath to anyone anymore "
        );
        _beneficiaryBalance[account] += amount;
        emit bequeathed(account, amount);
    }

    function changeDoctor(address newDoctor) public onlyOwner {
        _doctor = newDoctor;
        emit doctorSwapped(newDoctor);
    }

    function doctor() public view returns (address) {
        return _doctor;
    }

    function isDeceased() public view returns (bool) {
        return _isDead;
    }

    function addressHeritageBalance(address recipient)
        public
        view
        returns (uint256)
    {
        return _beneficiaryBalance[recipient];
    }
}
