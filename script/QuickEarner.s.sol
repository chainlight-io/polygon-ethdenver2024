// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {TheVault} from "src/v2/quick-earner/TheVault.sol";
import {FlashLoanPool} from "src/v2/quick-earner/FlashLoanPool.sol";

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract DeployQuickEarnerChallenge is Script {

    // ---- Usage ----
    // forge script script/QuickEarner.s.sol:DeployQuickEarnerChallenge --chain-id 2442 --rpc-url https://rpc.cardona.zkevm-rpc.com --broadcast

    IERC20 public constant DNVR = IERC20(0x84BbB983D8cF2F58bd9b2dE794a489d2e9798668);

    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYER_PRIVATE_KEY"));

        TheVault _theVault = new TheVault();
        FlashLoanPool _flashLoanPool = new FlashLoanPool();

        // seed the FlashLoanPool with DNVR
        uint256 _amount = 10_000_000 * 1e18;
        DNVR.approve(address(_flashLoanPool), _amount);
        _flashLoanPool.deposit(_amount);

        // deposit into the vault
        uint256 _userAmount = 5_000 * 1e18;
        DNVR.approve(address(_theVault), _userAmount);
        _theVault.deposit(_userAmount, vm.envAddress("DEPLOYER_ADDRESS"));

        // send rewards into the vault
        uint256 _rewards = 10_000 * 1e18;
        DNVR.transfer(address(_theVault), _rewards);

        vm.stopBroadcast();
    }
}