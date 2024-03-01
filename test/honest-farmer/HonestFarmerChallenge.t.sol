// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {LendingPool} from "src/honest-farmer/LendingPool.sol";

import {Attacker} from "./Attacker.sol";

import "forge-std/Test.sol";
import "forge-std/console.sol";

contract HonestFarmerChallenge is Test {

    LendingPool private _lendingPool;

    Attacker private _attacker;

    IERC20 private constant _WETH = IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);

    function setUp() external {

        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */

        vm.selectFork(vm.createFork(vm.envString("ARBITRUM_RPC_URL")));

        // Deploy the LendingPool contract
        _lendingPool = new LendingPool(
            address(_WETH),
            0x08F81E1637230d25b4ea6d4a69D74373E433Efb3, // oracle
            0xBA12222222228d8Ba445958a75a0704d566BF2C8, // vault
            0x64541216bAFFFEec8ea535BB71Fbc927831d0595 // balancerPoolToken
        );

        // Supply the LendingPool with 10 WETH
        deal({ token: address(_WETH), to: address(_lendingPool), give: 10 ether });

        // Deploy the Attacker contract
        _attacker = new Attacker(_lendingPool);
    }

    function testSolution() external {

        /** CODE YOUR SOLUTION INSIDE `Attacker.executeAttack` */

        _attacker.executeAttack();

        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        assertTrue(_lendingPool.deposits(address(_attacker)) > 0, "HonestFarmerChallenge: deposit not made");
        assertTrue(_WETH.balanceOf(address(_lendingPool)) == 0, "HonestFarmerChallenge: LendingPool still has WETH");
        assertTrue(_WETH.balanceOf(address(_attacker)) > 5 ether, "HonestFarmerChallenge: attacker did not make a profit");
    }
}