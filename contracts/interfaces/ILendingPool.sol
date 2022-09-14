// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.13;

interface ILendingPool {
    function deposit(address _reserve, uint256 _amount, uint16 _referralCode) external;
}