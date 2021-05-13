// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "./Ownable.sol";

contract Birthday is Ownable {
    using Address for address payable;

    uint256 private _birthday;

    event ReceivedM(address indexed sender, uint256 value);
    event Received(address indexed sender, uint256 value);
    event gotPresent(address indexed owner, uint256 value);

    constructor(address owner_, uint256 birthday_) Ownable(owner_) {
        _birthday = block.timestamp + (birthday_ * 1 days);
    }

    // Metamask deposit funds into the smartContract
    receive() external payable {
        require(block.timestamp <= _birthday, "Sorry mate it is too late");
        emit ReceivedM(msg.sender, msg.value);
    }

    //  funtion offer to deposit funds into the smartContract
    function offer() external payable {
        require(block.timestamp <= _birthday, "Sorry mate it is too late");
        emit Received(msg.sender, msg.value);
    }

    //function getPresent to withdray eth sent to the smartContract Birthday;
    function getPresent() public onlyOwner {
        require(
            address(this).balance > 0,
            "Birthday: sorry your friends are too cheap"
        );
        require(
            block.timestamp >= _birthday,
            "Birthday: Its not your birthday today"
        );
        payable(msg.sender).sendValue(address(this).balance);
        emit gotPresent(msg.sender, (address(this).balance));
    }

    function balanceFund() public view returns (uint256) {
        return address(this).balance;
    }

    function time() public view returns (uint256) {
        return block.timestamp;
    }
}
