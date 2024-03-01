// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Oracle
 * @author johnnyonline
 */
contract Oracle is Ownable {

    uint256 private _exchangeRate;

    event ExchangeRateUpdated(uint256 newRate);

    constructor(uint256 _initialRate) Ownable(msg.sender) {
        _exchangeRate = _initialRate;
    }

    function getExchangeRate() external view returns (uint256 _rate) {
        return _exchangeRate;
    }

    function updateExchangeRate(uint256 _newRate) external onlyOwner {
        _exchangeRate = _newRate;

        emit ExchangeRateUpdated(_newRate);
    }
}