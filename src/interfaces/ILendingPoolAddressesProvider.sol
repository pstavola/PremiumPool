// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

interface ILendingPoolAddressesProvider {
  function getLendingPool() external view returns (address);
}
