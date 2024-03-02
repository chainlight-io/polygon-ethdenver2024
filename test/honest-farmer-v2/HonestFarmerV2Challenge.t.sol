// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {LendingPoolV2} from "src/honest-farmer-v2/LendingPoolV2.sol";
import {Oracle} from "src/honest-farmer-v2/Oracle.sol";

import {Attacker} from "./Attacker.sol";

import "forge-std/Test.sol";
import "forge-std/console.sol";

contract HonestFarmerV2Challenge is Test {

    address private _liquidator;

    LendingPoolV2 private _lendingPoolV2;

    Attacker private _attacker;

    IERC20 private constant _WETH = IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
    IERC20 private constant _crvUSD = IERC20(0x498Bf2B1e120FeD3ad3D42EA2165E9b73f99C1e5);

    function setUp() external {

        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */

        vm.selectFork(vm.createFork(vm.envString("ARBITRUM_RPC_URL")));

        // Deploy the Oracle contract
        uint256 _initialRate = 10_000 * 1e18; // 1 ETH = 10,000 crvUSD :-)
        Oracle _oracle = new Oracle(_initialRate);

        // Deploy the LendingPoolV2 contract
        _lendingPoolV2 = new LendingPoolV2(address(_crvUSD), address(_oracle));

        // Supply the LendingPool with 100,000 crvUSD
        deal({ token: address(_crvUSD), to: address(_lendingPoolV2), give: 100_000 * 1e18 });

        // Deploy the Attacker contract
        _attacker = new Attacker(_lendingPoolV2);

        // Supply the Attacker with ETH worth of 200,000 crvUSD (exchange rate is 10,000 crvUSD per ETH)
        vm.deal({ account: address(_attacker), newBalance: 20 ether });

        // borrow all crvUSD available in the LendingPoolV2
        _attacker.borrow();

        // drop ETH price to 7,500 crvUSD per ETH (now collateral is worth 150,000 crvUSD, and can be liquidated)
        uint256 _newRate = 7_500 * 1e18; // 1 ETH = 7,500 crvUSD :-(
        _oracle.updateExchangeRate(_newRate);

        _liquidator = address(makeAddr(string(abi.encodePacked("liquidator"))));

        // Supply the liquidator with 100,000 crvUSD so he can liquidate the attacker's position
        deal({ token: address(_crvUSD), to: _liquidator, give: 100_000 * 1e18 });
    }

    function testSolution() external {

        /** CODE YOUR SOLUTION INSIDE `Attacker.executeAttack` */

        _attacker.executeAttack();

        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // try to liquidate the attacker's position
        vm.startPrank(_liquidator);
        _crvUSD.approve(address(_lendingPoolV2), 100_000 * 1e18);
        vm.expectRevert();
        _lendingPoolV2.liquidate(address(_attacker));
        vm.stopPrank();
    }
}
