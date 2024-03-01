// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

interface IOracle {

    /**
        @notice Fetches price of a given token in terms of ETH
        @param _token Address of token
        @return _price Price of token in terms of ETH
    */
    function getPrice(address _token) external view returns (uint256 _price);
}