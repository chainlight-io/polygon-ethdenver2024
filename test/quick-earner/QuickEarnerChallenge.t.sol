// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {TheVault} from "src/quick-earner/TheVault.sol";

import {Attacker} from "./Attacker.sol";

import "forge-std/Test.sol";
import "forge-std/console.sol";

contract QuickEarnerChallenge is Test {

    TheVault private _theVault;

    Attacker private _attacker;

    IERC20 private constant _WETH = IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);

    function setUp() external {

        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */

        vm.selectFork(vm.createFork(vm.envString("ARBITRUM_RPC_URL")));

        // Deploy The Vault contract
        _theVault = new TheVault(_WETH);

        // Deposit 10 WETH into The Vault for 5 different users
        for (uint256 i = 0; i < 5; i++) {
            address _user = address(makeAddr(string(abi.encodePacked("user", i))));
            uint256 _amount = 10 ether;
            deal({ token: address(_WETH), to: _user, give: _amount });

            vm.startPrank(_user);
            _WETH.approve(address(_theVault), _amount);
            _theVault.deposit(_amount, _user);
            vm.stopPrank();

            assertEq(_theVault.balanceOf(_user), _amount);
        }

        // Supply The Vault with 50 ETH
        vm.deal({ account: address(_theVault), newBalance: 50 ether });

        // Deploy the Attacker contract
        _attacker = new Attacker(_theVault);
    }

    function testSolution() external {

        /** CODE YOUR SOLUTION INSIDE `Attacker.executeAttack` */

        _attacker.executeAttack();

        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        assertTrue(address(_theVault).balance == 0, "QuickEarnerChallenge: TheVault still has ETH");
        assertTrue(_WETH.balanceOf(address(_attacker)) >= 45 ether, "QuickEarnerChallenge: Did not steal enough ETH");
    }
}