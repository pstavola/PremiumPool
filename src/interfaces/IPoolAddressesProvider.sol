// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

interface IPoolAddressesProvider {
  function getPool() external view returns (address);
}
