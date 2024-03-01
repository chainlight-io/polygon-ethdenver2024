// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {TheVault} from "src/quick-earner/TheVault.sol";

contract Attacker {

    TheVault private immutable _theVault;

    constructor(TheVault _vault) {
        _theVault = _vault;
    }

    function executeAttack() external {

        /** CODE YOUR SOLUTION HERE */

    }
}