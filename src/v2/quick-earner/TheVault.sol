// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC4626, ERC20, SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract TheVault is ERC4626 {

    using SafeERC20 for IERC20;

    uint256 private _totalAssets;

    uint256 constant BOUNTY = 500;
    uint256 constant FEE_DENOMINATOR = 10000;

    IERC20 public constant DNVR = IERC20(0x84BbB983D8cF2F58bd9b2dE794a489d2e9798668);

    event Harvest(address indexed _caller, address indexed _receiver, uint256 _rewards, uint256 _bounty);

    error NoRewards();

    constructor() ERC4626(DNVR) ERC20("TheVault", "TV") {}

    function totalAssets() public view override returns (uint256) {
        return _totalAssets;
    }

    function harvest(address _receiver) external returns (uint256 _rewards) {
        _rewards = DNVR.balanceOf(address(this)) - _totalAssets;
        if (_rewards > 0) {
            uint256 _harvestBounty = (_rewards * BOUNTY) / FEE_DENOMINATOR;
            _rewards -= _harvestBounty;

            _totalAssets += _rewards;

            emit Harvest(msg.sender, _receiver, _rewards, _harvestBounty);

            DNVR.safeTransfer(_receiver, _harvestBounty);
        } else {
            revert NoRewards();
        }
    }

    function _deposit(address _caller, address _receiver, uint256 _assets, uint256 _shares) internal override {
        _totalAssets += _assets;
        _mint(_receiver, _shares);

        emit Deposit(_caller, _receiver, _assets, _shares);

        DNVR.safeTransferFrom(_caller, address(this), _assets);
    }

    function _withdraw(address _caller, address _receiver, address _owner, uint256 _assets, uint256 _shares) internal override {
        if (_caller != _owner) {
            _spendAllowance(_owner, _caller, _shares);
        }

        _totalAssets -= _assets;
        _burn(_owner, _shares);

        emit Withdraw(_caller, _receiver, _owner, _assets, _shares);

        DNVR.safeTransfer(_receiver, _assets);
    }
}