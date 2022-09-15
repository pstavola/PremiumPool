// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.13;

interface IAToken {
    function balanceOf(address _user) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}