// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC4626, ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import {IWETH} from "./interfaces/IWETH.sol";

/**
 * @title TheVault
 * @author johnnyonline
 */
contract TheVault is ERC4626 {

    using Address for address payable;

    uint256 constant BOUNTY = 500;
    uint256 constant FEE_DENOMINATOR = 10000;

    IWETH public constant WETH = IWETH(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);

    event Harvest(address indexed _caller, address indexed _receiver, uint256 _rewards, uint256 _bounty);

    error NoRewards();

    constructor(IERC20 _asset) ERC4626(_asset) ERC20("TheVault", "TV") {}

    function harvest(address _receiver) external returns (uint256 _rewards) {
        _rewards = address(this).balance;
        if (_rewards > 0) {
            uint256 _harvestBounty = (_rewards * BOUNTY) / FEE_DENOMINATOR;
            _rewards -= _harvestBounty;

            emit Harvest(msg.sender, _receiver, _rewards, _harvestBounty);

            payable(_receiver).sendValue(_harvestBounty);
            WETH.deposit{value: _rewards}();
        } else {
            revert NoRewards();
        }
    }
}