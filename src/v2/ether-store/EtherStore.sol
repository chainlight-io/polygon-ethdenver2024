// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

contract EtherStore {

    using Address for address payable;
    
    uint256 public withdrawLimit = 0.1 ether;

    uint256 public balance;

    mapping(address => uint256) public lastWithdrawTime;

    function depositFunds() public payable {
        balance += msg.value;
    }

    function withdrawFunds(uint256 _weiToWithdraw) public {
        // check for sufficient funds
        require(balance >= _weiToWithdraw);
        // limit the withdrawl
        require(_weiToWithdraw <= withdrawLimit);
        // limit the time allowed to withdraw
        require(block.timestamp >= lastWithdrawTime[msg.sender] + 1 weeks);
		
        // send Wei to the massege sender
        payable(msg.sender).sendValue(_weiToWithdraw);

        balance -= _weiToWithdraw;
        lastWithdrawTime[msg.sender] = block.timestamp;
    }
}