// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ILendingPoolAddressesProvider.sol";
import "./interfaces/ILendingPool.sol";
import "./interfaces/IAToken.sol";
import "./DrawController.sol";
import "./Ticket.sol";
import "./LendingController.sol";

/**
 * @title PremiumPoolStorage
 * @author Patrizio Stavola
 * @notice PremiumPool storage contract stores and initializes all gloabal variables
*/
contract PremiumPoolStorage is
    Ownable
{
    /* ========== GLOBAL VARIABLES ========== */

    ///@notice Draw Controller instance
    DrawController public immutable draw;
    ///@notice Lending Controller instance
    LendingController public immutable lending;

    ///@notice $USDC token instance
    IERC20 immutable usdc;
    ///@notice $PPT token instance
    PremiumPoolTicket public immutable ticket;
    
    ///@notice Aave address registry
    ILendingPoolAddressesProvider immutable aProvider;
    ///@notice Aave $USDC lending pool instance
    ILendingPool immutable aPool;
    ///@notice Aave interest bearing token instance
    IAToken immutable aToken;

    ///@notice array used to cycle over the users partecipating to next draw
    address[] public users;
    ///@notice mapping to handle users array
    mapping(address => uint256) public userIndex;
    
    /* ========== CONSTRUCTOR ========== */

    /**
     * @notice initializing Draw Controller, Lending Controller, tokens, Aave details and users array.
     * @param _usdc address of $USDC token
     * @param _aPoolAddrProvider address of Aave address registry
     * @param _aToken address of Aave interest bearing token
     * @param _vrfCoordinator address of Chainlink VRF Coordinator
     * @param _link address of $LINK token
     * @param _subscriptionId Chainlink VRF subscription Id
     * @param _keyhash Chainlink VRF Key Hash
    */
    constructor(address _usdc, address _aPoolAddrProvider, address _aToken, address _vrfCoordinator, address _link, uint64 _subscriptionId, bytes32 _keyhash) {
        draw = new DrawController(_vrfCoordinator, _link, _subscriptionId, _keyhash);
        lending = new LendingController();
        usdc = IERC20(_usdc);
        ticket = new PremiumPoolTicket();
        aProvider = ILendingPoolAddressesProvider(address(_aPoolAddrProvider));
        aPool = ILendingPool(aProvider.getLendingPool());
        aToken = IAToken(_aToken);
        users = new address[](0);
    }
}
