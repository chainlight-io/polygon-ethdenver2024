// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IFlashLoanEtherReceiver {
    function execute() external;
}

contract LendingPool {

    using SafeERC20 for IERC20;

    IERC20 public constant DNVR = IERC20(0x84BbB983D8cF2F58bd9b2dE794a489d2e9798668);

    mapping(address => uint256) private balances;

    error RepayFailed();

    event Deposit(address indexed who, uint256 amount);
    event Withdraw(address indexed who, uint256 amount);

    function deposit(uint256 _amount) external {
        balances[msg.sender] += _amount;

        DNVR.safeTransferFrom(msg.sender, address(this), _amount);

        emit Deposit(msg.sender, _amount);
    }

    function withdraw() external {
        uint256 _amount = balances[msg.sender];
        
        delete balances[msg.sender];

        emit Withdraw(msg.sender, _amount);

        DNVR.safeTransfer(msg.sender, _amount);
    }

    function flashLoan(uint256 _amount) external {
        uint256 _balanceBefore = DNVR.balanceOf(address(this));

        DNVR.safeTransfer(msg.sender, _amount);
        IFlashLoanEtherReceiver(msg.sender).execute();

        if (DNVR.balanceOf(address(this)) < _balanceBefore) revert RepayFailed();
    }
}