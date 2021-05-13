// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "./Ownable.sol";

contract SmartWallet is Ownable {
    using Address for address payable;

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _whitelist;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _tax;
    uint256 private _profit;

    event Deposited(address indexed sender, uint256 amount);
    event Withdrew(address indexed sender, uint256 amount);
    event Transfered(
        address indexed sender,
        address indexed recipient,
        uint256 amount
    );
    event setWhitelisted(address indexed account, bool whilelist);
    event Approval(
        address indexed account,
        address indexed spender,
        uint256 amount
    );

    constructor(address owner_, uint256 tax_) Ownable(owner_) {
        require(tax_ >= 0 && tax_ <= 100, "SmartWallet: Invalid percentage");
        _tax = tax_;
    }

    function setTax(uint256 tax_) public onlyOwner {
        require(tax_ >= 0 && tax_ <= 100, "SmartWallet: Invalid percentage");
        _tax = tax_;
    }

    function setWhitelist(address account) public onlyOwner {
        _whitelist[account] = !_whitelist[account];
        emit setWhitelisted(account, _whitelist[account]);
    }

    function approve(address spender, uint256 amount) public {
        require(
            spender != address(0),
            "SmartWallet: approve to the zero address"
        );
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }

    receive() external payable {
        _deposit(msg.sender, msg.value);
    }

    function deposit() external payable {
        _deposit(msg.sender, msg.value);
    }

    function withdrawall() public {
        uint256 amount = _balances[msg.sender];
        _withdraw(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        _withdraw(msg.sender, amount);
    }

    function withdrawProfit() public onlyOwner {
        require(_profit > 0, "SmartWallet: Nothing to withdraw");
        uint256 amount = _profit;
        _profit = 0;
        payable(msg.sender).sendValue(amount);
    }

    function transfer(address recipient, uint256 amount) public {
        require(
            _balances[msg.sender] >= amount,
            "SmartWallet: Insufficient Balance"
        );
        require(
            recipient != address(0),
            "SmartWallet: transfer to the zero address"
        );
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfered(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public {
        require(
            _allowances[sender][msg.sender] >= amount,
            "SmartWallet: over the allowance"
        );
        require(
            _balances[sender] >= amount,
            "SmartWallet: Not enough Ether to transfer"
        );
        require(
            recipient != address(0),
            "SmartWallet: transfer to the zero address"
        );
        _allowances[sender][msg.sender] -= amount;
        _balances[sender] -= amount;
        _balances[recipient] += amount;
    }

    function _deposit(address sender, uint256 amount) private {
        _balances[sender] += amount;
        emit Deposited(sender, amount);
    }

    function _withdraw(address recipient, uint256 amount) private {
        require(_balances[recipient] > 0, "SmartWallet: No Balance");
        require(
            _balances[recipient] >= amount,
            "SmartWallet: You do not have enough ETH"
        );
        uint256 fees = 0;
        if (_whitelist[recipient] != true) {
            fees = _estimateFees(amount, _tax);
        }
        uint256 afterFeesAmount = amount - fees;
        _balances[recipient] -= amount;
        _profit += fees;
        payable(msg.sender).sendValue(afterFeesAmount);
        emit Withdrew(msg.sender, afterFeesAmount);
    }

    function _estimateFees(uint256 amount, uint256 tax_)
        private
        pure
        returns (uint256)
    {
        return (amount * tax_) / 100;
    }

    function balances() public view returns (uint256) {
        return _balances[msg.sender];
    }

    function isWhitelist(address account) public view returns (bool) {
        return _whitelist[account];
    }

    function balanceSmartWallet() public view returns (uint256) {
        return address(this).balance;
    }
}
