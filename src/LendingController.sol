// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ILendingPool.sol";
import "./interfaces/IAToken.sol";

/**
 * @title LendingController
 * @author Patrizio Stavola
 * @notice Lending Controller responsible for managing Aave Lending Pool deposits and withdrawal
*/
contract LendingController is
    Ownable
{
    /* ========== FUNCTIONS ========== */

    /**
     * @notice allows users to deposit $USDC into Aave Lending Pool. Users must manually approve transfer by contract beforehand
     * @param _sender address of user making the deposit
     * @param _usdcAmount amount to deposit
     * @param _usdc address of $USDC token
     * @param _aPool address of Aave Lending Pool
    */
    function deposit(address _sender, uint256 _usdcAmount, address _usdc, address _aPool) public {
        IERC20(_usdc).transferFrom(_sender, address(this), _usdcAmount);
        IERC20(_usdc).approve(address(_aPool), _usdcAmount);
        ILendingPool(_aPool).deposit(address(_usdc), _usdcAmount, address(this), 0);
    }

    /**
     * @notice allows users to withdraw $USDC from Aave Lending Pool.
     * @param _sender address of user making the withdrawal
     * @param _usdcAmount amount to withdraw
     * @param _usdc address of $USDC token
     * @param _usdc address of Aave interest bearing token
     * @param _aPool address of Aave Lending Pool
    */
    function withdraw(address _sender, uint256 _usdcAmount, address _usdc, address aToken, address _aPool) public {
        require(IAToken(aToken).balanceOf(address(this)) >= _usdcAmount, "AToken: You cannot withdraw more than deposited!");
        IAToken(aToken).approve(address(_aPool), _usdcAmount);
        ILendingPool(_aPool).withdraw(address(_usdc), _usdcAmount, _sender);
    }
}
