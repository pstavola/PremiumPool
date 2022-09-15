// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.13;

interface ILendingPool {
    function deposit(address _reserve, uint256 _amount, uint16 _referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
}