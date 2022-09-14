// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./DrawController.sol";

/**
 * @title PremiumPool
 * @author patricius
 * @notice PremiumPool main contract
 * @dev 
 */
contract PremiumPool is
    Ownable
{
    /* ========== GLOBAL VARIABLES ========== */

    DrawController public draw; // draw controller instance
    IERC20 public usdc; // $USDC instance
    IERC20 public ticket; // ticket instance

    mapping(address => uint256) public userIndex;
    uint256 public usersCount;
    address[] public users;
    uint256 public usdcDeposit;
    uint256 public prize;

    /* ========== EVENTS ========== */

    event Deposit(address user, uint256 usdcAmount);
    event Withdraw(address user, uint256 usdcAmount);

    /* ========== CONSTRUCTOR ========== */

    constructor(address _usdc, address _ticket, address vrfCoordinator, address link, bytes32 _keyhash, uint256 _fee) {
        usdc = IERC20(_usdc);
        ticket = IERC20(_ticket);
        draw = new DrawController(vrfCoordinator, link, _keyhash, _fee);
        users = new address[](0);
    }

    /* ========== FUNCTIONS ========== */

    /**
     * @notice allows users to deposit usdc. Users must manually approve transfer by contract beforehand
     */
    function deposit(uint256 _usdcAmount) public {
        require(_usdcAmount >= 100 * (10**18), "minimum deposit is 100 $USDC");

        usdc.transferFrom(msg.sender, address(this), _usdcAmount);
        ticket.transferFrom(address(this), msg.sender, _usdcAmount);
        
        if(userIndex[msg.sender] == 0) {
            usersCount++;
        }
        userIndex[msg.sender] += users.length;
        users.push(msg.sender);

        emit Deposit(msg.sender, _usdcAmount);
    }

    /**
     * @notice allows users to withdraw usdc. Users must manually approve transfer by contract beforehand
     * @param _usdcAmount usdc amount
     */
    function withdraw(uint256 _usdcAmount) public {
        require(_usdcAmount >= 0, "cant withdraw 0 $USDC");
        require(ticket.balanceOf(msg.sender) >= _usdcAmount, "user has not enough balance");
        require(usdc.balanceOf(address(this)) >= _usdcAmount, "contract has not enough balance");

        ticket.transferFrom(msg.sender, address(this), _usdcAmount);
        usdc.transferFrom(address(this), msg.sender, _usdcAmount);

        uint256 index = userIndex[msg.sender];
        if(ticket.balanceOf(msg.sender) == 0){
            delete users[index];
            usersCount--;
        }
        
        emit Withdraw(msg.sender, _usdcAmount);
    }

    /**
     * @notice close the draw and request a random number to pick the winner.
     */
    function pickWinner() public onlyOwner {
        uint256 currentDrawId = draw.drawId();
        (, bool currentDrawIsOpen, , uint256 currentDrawEndTime, uint256 prize, uint256 usdcDeposit, ) = draw.draws(currentDrawId);

        require(block.timestamp > currentDrawEndTime,"Draw endtime still not reached");
        require(!currentDrawIsOpen,"Draw already closed");
        require(usersCount != 0, "There has been no participation during this draw");

        draw.updatePrize(prize);
        draw.updateDeposit(usdcDeposit);
        draw.closeDraw();
    }
}
