// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {FixedPoint} from "./library/FixedPoint.sol";

import {IOracle} from "./interfaces/IOracle.sol";
import {IVault} from "./interfaces/IVault.sol";
import {IPool} from "./interfaces/IPool.sol";

/**
 * @title LendingPool
 * @author johnnyonline
 */
contract LendingPool {

    using SafeERC20 for IERC20Metadata;

    using FixedPoint for uint256;

    mapping(address => uint256) public deposits;

    address public immutable balancerPoolToken;

    IERC20Metadata public immutable token;

    IOracle public immutable oracle;
    IVault public immutable vault;

    uint256 public constant DEPOSIT_FACTOR = 2;
    uint256 public constant DECIMALS = 1e18;

    event Borrowed(address indexed account, address recipient, uint256 depositRequired, uint256 borrowAmount);

    constructor(address _token, address _oracle, address _vault, address _balancerPoolToken) {
        token = IERC20Metadata(_token);

        oracle = IOracle(_oracle);
        vault = IVault(_vault);

        balancerPoolToken = _balancerPoolToken;
    }

    /// @notice Allows borrowing tokens by first depositing two times their value in `balancerPoolToken`
    function borrow(uint256 _amount, address _recipient) external {
        uint256 _depositRequired = getDepositRequired(_amount);

        IERC20Metadata(balancerPoolToken).safeTransferFrom(msg.sender, address(this), _depositRequired);

        deposits[msg.sender] += _depositRequired;

        emit Borrowed(msg.sender, _recipient, _depositRequired, _amount);

        // Fails if the pool doesn't have enough tokens in liquidity
        token.safeTransfer(_recipient, _amount);
    }

    function getDepositRequired(uint256 _amount) public view returns (uint256) {
        return _amount * DEPOSIT_FACTOR * DECIMALS / getBalancerPoolTokenPrice();
    }

    // Returns price denominated in ETH with 18 decimals
    function getBalancerPoolTokenPrice() public view returns (uint256) {
        IPool _token = IPool(balancerPoolToken);
        (address[] memory _poolTokens, uint256[] memory _balances,) = vault.getPoolTokens(_token.getPoolId());

        uint256[] memory _weights = _token.getNormalizedWeights();

        uint256 _length = _weights.length;
        uint256 _temp = 1e18;
        uint256 _invariant = 1e18;
        for(uint256 i; i < _length; i++) {
            _temp = _temp.mulDown((oracle.getPrice(_poolTokens[i]).divDown(_weights[i])).powDown(_weights[i]));
            _invariant = _invariant.mulDown((_balances[i] * 10 ** (18 - IERC20Metadata(_poolTokens[i]).decimals())).powDown(_weights[i]));
        }

        return _invariant.mulDown(_temp).divDown(_token.totalSupply());
    }
}