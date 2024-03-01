// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {LendingPool} from "src/v2/flash-cash/LendingPool.sol";

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract DeployFlashCashChallenge is Script {

    // ---- Usage ----
    // forge script script/FlashCash.s.sol:DeployFlashCashChallenge --chain-id 2442 --rpc-url https://rpc.cardona.zkevm-rpc.com --broadcast

    IERC20 public constant DNVR = IERC20(0x84BbB983D8cF2F58bd9b2dE794a489d2e9798668);

    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYER_PRIVATE_KEY"));

        LendingPool _lendingPool = new LendingPool();

        // seed the lending pool with DNVR
        uint256 _amount = 10_000 * 1e18;
        DNVR.approve(address(_lendingPool), _amount);
        _lendingPool.deposit(_amount);

        vm.stopBroadcast();
    }
}