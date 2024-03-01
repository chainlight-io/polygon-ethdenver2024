// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {YieldOptimizerVault} from "src/effective-altruist/YieldOptimizerVault.sol";

import {Attacker} from "./Attacker.sol";

import "forge-std/Test.sol";
import "forge-std/console.sol";

contract EffectiveAltruistChallenge is Test {

    address private _alice;

    YieldOptimizerVault private _yieldOptimizerVault;

    Attacker private _attacker;

    IERC20 private constant _crvUSD = IERC20(0x498Bf2B1e120FeD3ad3D42EA2165E9b73f99C1e5);

    function setUp() external {

        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */

        vm.selectFork(vm.createFork(vm.envString("ARBITRUM_RPC_URL")));

        // Deploy the YieldOptimizerVault contract
        _yieldOptimizerVault = new YieldOptimizerVault(_crvUSD);

        _alice = address(makeAddr("alice"));

        // Supply Alice with 10,000 crvUSD
        deal({ token: address(_crvUSD), to: _alice, give: 10_000 * 1e18 });

        // Deploy the Attacker contract
        _attacker = new Attacker(_yieldOptimizerVault, _crvUSD);

        // Supply the Attacker with 10 crvUSD
        deal({ token: address(_crvUSD), to: address(_attacker), give: 10 * 1e18 });
    }

    function testSolution() external {

        /** CODE YOUR SOLUTION INSIDE `Attacker.executeAttack` */

        _attacker.executeAttack();

        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        vm.startPrank(_alice);
        _crvUSD.approve(address(_yieldOptimizerVault), 10_000 * 1e18);
        _yieldOptimizerVault.deposit(10_000 * 1e18, _alice);
        vm.stopPrank();

        assertTrue(_yieldOptimizerVault.shares(_alice) < 10_000 * 1e18, "QuickEarnerChallenge: Did not rug Alice");
    }
}