// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LendingPoolV2} from "src/honest-farmer-v2/LendingPoolV2.sol";

contract Attacker {

    LendingPoolV2 private immutable _lendingPoolV2;

    constructor(LendingPoolV2 _pool) {
        _lendingPoolV2 = _pool;
    }

    function borrow() public {
        _lendingPoolV2.borrow{ value: 20 ether }(100_000 * 1e18, address(this));
    }

    function executeAttack() public {

        /** CODE YOUR SOLUTION HERE */

    }

    receive() external payable {
        executeAttack();
    }
}