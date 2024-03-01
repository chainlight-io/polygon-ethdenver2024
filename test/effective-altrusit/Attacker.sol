// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {YieldOptimizerVault} from "src/effective-altruist/YieldOptimizerVault.sol";

contract Attacker {

    IERC20 private immutable _token;

    YieldOptimizerVault private immutable _yieldOptimizerVault;

    constructor(YieldOptimizerVault _vault, IERC20 __token) {
        _yieldOptimizerVault = _vault;
        _token = __token;
    }

    function executeAttack() external {

        /** CODE YOUR SOLUTION HERE */

    }
}