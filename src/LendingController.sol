// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IPool.sol";
import "./interfaces/IAToken.sol";

/**
 * @title PremiumPool
 * @author patricius
 * @notice PremiumPool main contract
 * @dev 
 */
contract LendingController is
    Ownable
{
    /* ========== GLOBAL VARIABLES ========== */   

    /* ========== EVENTS ========== */

    event Deposit(address indexed user, uint256 usdcAmount);
    event Withdraw(address indexed user, uint256 usdcAmount);

    /* ========== FUNCTIONS ========== */

    /**
     * @notice allows users to deposit usdc. Users must manually approve transfer by contract beforehand
     */
    function deposit(address sender, uint256 _usdcAmount, address _usdc, address _aPool) public {
        IERC20(_usdc).approve(address(_aPool), _usdcAmount);
        IPool(_aPool).supply(address(_usdc), _usdcAmount, address(this), 0);
        
        emit Deposit(sender, _usdcAmount);
    }

     /**
     * @notice allows users to withdraw usdc. Users must manually approve transfer by contract beforehand
     * @param _usdcAmount usdc amount
     */
    function withdraw(address sender, uint256 _usdcAmount, address _usdc, address aToken, address _aPool) public {
        IAToken(aToken).approve(address(_aPool), _usdcAmount);
        IPool(_aPool).withdraw(address(_usdc), _usdcAmount, sender);

        emit Withdraw(sender, _usdcAmount);
    }
}