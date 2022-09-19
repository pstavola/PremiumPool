// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ILendingPool.sol";
import "./interfaces/IAToken.sol";
import "./DrawController.sol";
import "./Ticket.sol";

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

    DrawController public immutable draw; // draw controller instance
    IERC20 immutable usdc; // $USDC instance
    PremiumPoolTicket immutable ticket; // ticket instance
    ILendingPool immutable aPool; // aave usdc lending pool
    IAToken immutable aToken; // aave interest bearing token

    mapping(address => uint256) internal userIndex;
    uint256 public usersCount;
    address[] public users;
    mapping(address => uint256) public userDepositedUsdc;
    uint256 public usdcDeposit;
    uint256 public prize;

    /* ========== EVENTS ========== */

    event Deposit(address user, uint256 usdcAmount);
    event Withdraw(address user, uint256 usdcAmount);

    /* ========== CONSTRUCTOR ========== */

    constructor(address _usdc, address _aPool, address _aToken, address vrfCoordinator, address link, bytes32 _keyhash, uint256 _fee) {
        usdc = IERC20(_usdc);
        ticket = new PremiumPoolTicket();
        aPool = ILendingPool(_aPool);
        aToken = IAToken(_aToken);
        draw = new DrawController(vrfCoordinator, link, _keyhash, _fee);
        users = new address[](0);
    }

    /* ========== FUNCTIONS ========== */

    /**
     * @notice allows users to deposit usdc. Users must manually approve transfer by contract beforehand
     */
    function deposit(uint256 _usdcAmount) public {
        require(_usdcAmount >= 100 * (10**18), "minimum deposit is 100 $USDC");

        if(userIndex[msg.sender] == 0) {
            usersCount++;
            userIndex[msg.sender] = users.length;
            users.push(msg.sender);
        }
        userDepositedUsdc[msg.sender] += _usdcAmount;
        usdcDeposit += _usdcAmount;
        usdc.transferFrom(msg.sender, address(this), _usdcAmount);
        ticket.mint(msg.sender, _usdcAmount);
        depositToAave(_usdcAmount);
    }

    /**
     * @notice deposit to aave pool
     */
    function depositToAave(uint256 _usdcAmount) private {
        usdc.approve(address(aPool), _usdcAmount);
        aPool.deposit(address(usdc), _usdcAmount, 0);
        
        emit Deposit(msg.sender, _usdcAmount);
    }

    /**
     * @notice allows users to withdraw usdc. Users must manually approve transfer by contract beforehand
     * @param _usdcAmount usdc amount
     */
    function withdraw(uint256 _usdcAmount) public {
        require(userDepositedUsdc[msg.sender] >= _usdcAmount, "You cannot withdraw more than deposited!");

        ticket.burn(msg.sender, _usdcAmount);
        withdrawFromAave(_usdcAmount, msg.sender);

        userDepositedUsdc[msg.sender] -= _usdcAmount;
        usdcDeposit -= _usdcAmount;
        if(userDepositedUsdc[msg.sender] == 0){
            usersCount--;
            delete users[userIndex[msg.sender]];
            userIndex[msg.sender] = 0;
        }

        emit Withdraw(msg.sender, _usdcAmount);
    }

    /**
     * @notice redeem aave tokens
     * @param _usdcAmount usdc amount
     */
    function withdrawFromAave(uint256 _usdcAmount, address _to) private {
        aToken.approve(address(aPool), _usdcAmount);
        aPool.withdraw(address(usdc), _usdcAmount, _to);
    }

    /**
     * @notice close the draw and request a random number to pick the winner.
     */
    function pickWinner() public onlyOwner {
        uint256 currentDrawId = draw.drawId();
        (, bool currentDrawIsOpen, , uint256 currentDrawEndTime, , , ) = draw.draws(currentDrawId);

        require(block.timestamp >= currentDrawEndTime,"Draw endtime still not reached");
        require(currentDrawIsOpen, "Draw already closed");
        require(usersCount != 0, "There has been no participation during this draw");

        prize = aToken.balanceOf(address(this)) - usdcDeposit;
        require(prize > 0, "There is no winning prize for this draw");

        draw.updatePrize(prize);
        draw.updateDeposit(usdcDeposit);
        draw.closeDraw();

        (, , , , , , address winner) = draw.draws(currentDrawId);
        userDepositedUsdc[winner] += prize;
        usdcDeposit += prize;
        ticket.mint(winner, prize);

        createNewDraw();
    }

    /**
     * @notice create a new draw
     */
    function createNewDraw() public onlyOwner {
        draw.createDraw();
    }

    /**
     * @notice get list of users
     */
    function getUsers() public view returns (address[] memory) {
        return users;
    }
}
