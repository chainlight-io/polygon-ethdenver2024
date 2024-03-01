// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title YieldOptimizerVault
 * @author johnnyonline
 */
contract YieldOptimizerVault {

    using SafeERC20 for IERC20;

    uint256 public totalSupply;

    mapping(address => uint256) public shares;

    IERC20 public immutable token;

    event Deposit(address indexed sender, address indexed receiver, uint256 assets, uint256 shares);
    event Withdraw(address indexed sender, address indexed receiver, uint256 assets, uint256 shares);

    constructor(IERC20 _token) {
        token = _token;
    }

    function deposit(uint256 _assets, address _receiver) public virtual returns (uint256 _shares) {
        _shares = _convertToShares(_assets);

        shares[_receiver] += _shares;
        totalSupply += _shares;

        emit Deposit(msg.sender, _receiver, _assets, _shares);

        token.safeTransferFrom(msg.sender, address(this), _assets);
    }

    function withdraw(uint256 _shares, address _receiver) public virtual returns (uint256 _assets) {
        _assets = _convertToAssets(_shares);

        shares[msg.sender] -= _shares;
        totalSupply -= _shares;

        emit Withdraw(msg.sender, _receiver, _assets, _shares);

        token.safeTransfer(_receiver, _assets);
    }

    function totalAssets() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function _convertToShares(uint256 _assets) internal view virtual returns (uint256) {
        uint256 _supply = totalSupply;
        return _supply == 0 ? _assets : _assets * _supply / totalAssets();
    }

    function _convertToAssets(uint256 _shares) internal view virtual returns (uint256) {
        uint256 _supply = totalSupply;
        return _supply == 0 ? _shares : _shares * totalAssets() / _supply;
    }
}