// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "./interfaces/ILendingPoolAddressesProvider.sol";
//import "./interfaces/ILendingPool.sol";
import "./interfaces/IPoolAddressesProvider.sol";
import "./interfaces/IPool.sol";
import "./interfaces/IAToken.sol";
import "./DrawController.sol";
import "./Ticket.sol";
import "./LendingController.sol";

/**
 * @title PremiumPoolStorage
 * @author patricius
 * @notice PremiumPool storage
 * @dev 
 */
contract PremiumPoolStorage is
    Ownable
{
    /* ========== GLOBAL VARIABLES ========== */

    DrawController public immutable draw; // draw controller instance
    LendingController public immutable lending; // lending controller instance
    IERC20 immutable usdc; // $USDC instance
    PremiumPoolTicket public immutable ticket; // ticket instance
    IPoolAddressesProvider immutable aProvider; // aave address registry
    IPool immutable aPool; // aave usdc lending pool
    IAToken immutable aToken; // aave interest bearing token

    mapping(address => uint256) public userIndex;
    address[] public users;

    /* ========== CONSTRUCTOR ========== */

    constructor(address _usdc, address _aPoolAddrProvider, address _aToken, address vrfCoordinator, address _link, uint64 _subscriptionId, bytes32 _keyhash) {
        usdc = IERC20(_usdc);
        ticket = new PremiumPoolTicket();
        aProvider = IPoolAddressesProvider(address(_aPoolAddrProvider));
        aPool = IPool(aProvider.getPool());
        aToken = IAToken(_aToken);
        draw = new DrawController(vrfCoordinator, _link, _subscriptionId, _keyhash);
        lending = new LendingController();
        users = new address[](0);
    }
}
