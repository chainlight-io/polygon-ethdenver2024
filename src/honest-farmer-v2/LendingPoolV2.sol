// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {Oracle} from "./Oracle.sol";

/**
 * @title LendingPoolV2
 * @author johnnyonline
 */
contract LendingPoolV2 {

    using SafeERC20 for IERC20Metadata;

    using Address for address payable;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrowed;

    IERC20Metadata public immutable token;
    Oracle public immutable oracle;

    uint256 public constant DEPOSIT_FACTOR = 2;
    uint256 public constant DECIMALS = 1e18;
    uint256 public constant LIQ_THRESHOLD = 15;
    uint256 public constant LIQ_BOUNTY = 1;
    uint256 public constant PRECISION = 10;

    event Borrowed(address account, address recipient, uint256 depositRequired, uint256 borrowAmount);
    event Liquidated(address borrower, address liquidator, uint256 collateral, uint256 borrowedAmount, uint256 remainingCollateral);

    error InvalidToken();
    error InvalidValue();
    error ZeroAmount();
    error Solvent();

    constructor(address _token, address _oracle) {
        if (IERC20Metadata(_token).decimals() != 18) revert InvalidToken();

        token = IERC20Metadata(_token);
        oracle = Oracle(_oracle);
    }

    /// @notice Allows borrowing tokens by first depositing two times their value in ETH
    function borrow(uint256 _amount, address _recipient) external payable {
        if (_amount == 0) revert ZeroAmount();

        uint256 _depositRequired = getDepositRequired(_amount);
        if (msg.value != _depositRequired) revert InvalidValue();

        deposits[msg.sender] += _depositRequired;
        borrowed[msg.sender] += _amount;

        emit Borrowed(msg.sender, _recipient, _depositRequired, _amount);

        // Fails if the pool doesn't have enough tokens in liquidity
        token.safeTransfer(_recipient, _amount);
    }

    /// @notice Allows a third party to repay a borrower's debt if they have become insolvent
    function liquidate(address _borrower) external {

        uint256 _borrowedAmount = borrowed[_borrower];
        uint256 _collateral = deposits[_borrower];
        uint256 _exchangeRate = getExchangeRate();
        if (_collateral * _exchangeRate / DECIMALS > _borrowedAmount * LIQ_THRESHOLD / PRECISION) revert Solvent();

        uint256 _borrowedAmountInETH = _borrowedAmount * DECIMALS / _exchangeRate;
        uint256 _bounty = _collateral * LIQ_BOUNTY / PRECISION;
        uint256 _remainingCollateral = _collateral - _borrowedAmountInETH - _bounty;

        deposits[_borrower] = 0;
        borrowed[_borrower] = 0;

        emit Liquidated(_borrower, msg.sender, _collateral, _borrowedAmount, _remainingCollateral);

        token.safeTransferFrom(msg.sender, address(this), _borrowedAmount);

        payable(msg.sender).sendValue(_borrowedAmountInETH + _bounty);
        payable(_borrower).sendValue(_remainingCollateral);
    }

    function getDepositRequired(uint256 _amount) public view returns (uint256) {
        return _amount * DEPOSIT_FACTOR * DECIMALS / getExchangeRate();
    }

    // Returns crvUSD/ETH price with 18 decimals
    function getExchangeRate() public view returns (uint256) {
        return oracle.getExchangeRate();
    }
}