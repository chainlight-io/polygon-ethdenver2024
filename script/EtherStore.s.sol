// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {EtherStore} from "src/v2/ether-store/EtherStore.sol";

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract DeployEtherStoreChallenge is Script {

    // ---- Usage ----
    // forge script script/EtherStore.s.sol:DeployEtherStoreChallenge --chain-id 2442 --rpc-url https://rpc.cardona.zkevm-rpc.com --broadcast

    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYER_PRIVATE_KEY"));

        EtherStore _etherStore = new EtherStore();

        // seed the EtherStore
        _etherStore.depositFunds{value: 10 ether}();

        vm.stopBroadcast();
    }
}