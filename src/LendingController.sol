// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ILendingPool.sol";
import "./interfaces/IAToken.sol";

/**
 * @title LendingController
 * @author patricius
 * @notice PremiumPool lending controller
 * @dev 
 */
contract LendingController is
    Ownable
{
    /* ========== FUNCTIONS ========== */

    /**
     * @notice allows users to deposit usdc. Users must manually approve transfer by contract beforehand
     */
    function deposit(address sender, uint256 _usdcAmount, address _usdc, address _aPool) public {
        IERC20(_usdc).transferFrom(sender, address(this), _usdcAmount);
        IERC20(_usdc).approve(address(_aPool), _usdcAmount);
        ILendingPool(_aPool).deposit(address(_usdc), _usdcAmount, address(this), 0); // REMOVED FOR TESTING PURPOSES
    }

     /**
     * @notice allows users to withdraw usdc.
     * @param _usdcAmount usdc amount
     */
    function withdraw(address sender, uint256 _usdcAmount, address _usdc, address aToken, address _aPool) public {
        IAToken(aToken).approve(address(_aPool), _usdcAmount);
        //IERC20(_usdc).transfer(sender, _usdcAmount);
        ILendingPool(_aPool).withdraw(address(_usdc), _usdcAmount, sender); // REMOVED FOR TESTING PURPOSES
    }
}