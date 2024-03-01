// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Timelock} from "src/v2/time-traveler/Timelock.sol";

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract DeployTimeTravelerChallenge is Script {

    // ---- Usage ----
    // forge script script/TimeTraveler.s.sol:DeployTimeTravelerChallenge --verify --legacy --etherscan-api-key J8WCBMC8XAXKKZS3AYR1RRGJ7RMFAIXBRY --verifier-url https://cardona-zkevm.polygonscan.com/api --chain-id 2442 --rpc-url https://rpc.cardona.zkevm-rpc.com --broadcast
    // forge verify-contract --watch --chain-id 2442 --compiler-version v0.8.23+commit.f704f362 --etherscan-api-key J8WCBMC8XAXKKZS3AYR1RRGJ7RMFAIXBRY --verifier-url https://cardona-zkevm.polygonscan.com/api 0x2Fb0b0D852B3EdeA91EdC0620812082241c52Ad9 src/v2/time-traveler/Timelock.sol:Timelock
    // forge verify-contract --watch --chain-id 2442 --compiler-version v0.8.23+commit.f704f362 --chain polygon --verifier-url https://cardona-zkevm.polygonscan.com/api 0x2Fb0b0D852B3EdeA91EdC0620812082241c52Ad9 src/v2/time-traveler/Timelock.sol:Timelock

    IERC20 public constant DNVR = IERC20(0x84BbB983D8cF2F58bd9b2dE794a489d2e9798668);

    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYER_PRIVATE_KEY"));

        Timelock _timeLock = new Timelock();

        // deposit into the Timelock
        uint256 _amount = 10_000 * 1e18;
        DNVR.approve(address(_timeLock), _amount);
        _timeLock.deposit(_amount);

        vm.stopBroadcast();

        console.log("Timelock deployed at:", address(_timeLock));
    }
}