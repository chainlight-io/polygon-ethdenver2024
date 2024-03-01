// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LendingPool} from "src/honest-farmer/LendingPool.sol";

contract Attacker {

    LendingPool private immutable _lendingPool;

    constructor(LendingPool _pool) {
        _lendingPool = _pool;
    }

    function executeAttack() external {

        /** CODE YOUR SOLUTION HERE */

    }
}