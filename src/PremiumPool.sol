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
    PremiumPoolTicket public immutable ticket; // ticket instance
    ILendingPool immutable aPool; // aave usdc lending pool
    IAToken immutable aToken; // aave interest bearing token

    mapping(address => uint256) public userIndex;
    address[] public users;

    /* ========== EVENTS ========== */

    event Deposit(address indexed user, uint256 usdcAmount);
    event Withdraw(address indexed user, uint256 usdcAmount);

    /* ========== CONSTRUCTOR ========== */

    constructor(address _usdc, address _aPool, address _aToken, address vrfCoordinator, address _link, uint64 _subscriptionId, bytes32 _keyhash) {
        usdc = IERC20(_usdc);
        ticket = new PremiumPoolTicket();
        aPool = ILendingPool(_aPool);
        aToken = IAToken(_aToken);
        draw = new DrawController(vrfCoordinator, _link, _subscriptionId, _keyhash);
        users = new address[](0);
    }

    /* ========== FUNCTIONS ========== */

    /**
     * @notice allows users to deposit usdc. Users must manually approve transfer by contract beforehand
     */
    function deposit(uint256 _usdcAmount) public {
        if(userIndex[msg.sender] == 0) {
            userIndex[msg.sender] = users.length;
            users.push(msg.sender);
        }
        usdc.transferFrom(msg.sender, address(this), _usdcAmount);
        (bool success, ) = address(this).call(abi.encodeWithSignature("mintTicket(address,uint256)", msg.sender, _usdcAmount));
        require(success);
        depositToAave(_usdcAmount);

        emit Deposit(msg.sender, _usdcAmount);
    }

    /**
     * @notice deposit to aave pool
     */
    function depositToAave(uint256 _usdcAmount) private {
        usdc.approve(address(aPool), _usdcAmount);
        aPool.deposit(address(usdc), _usdcAmount, address(this), 0);
    }

    /**
     * @notice allows users to withdraw usdc. Users must manually approve transfer by contract beforehand
     * @param _usdcAmount usdc amount
     */
    function withdraw(uint256 _usdcAmount) public {
        require(ticket.balanceOf(msg.sender) >= _usdcAmount, "You cannot withdraw more than deposited!");

        ticket.burn(msg.sender, _usdcAmount);
        withdrawFromAave(_usdcAmount, msg.sender);

        if(ticket.balanceOf(msg.sender) == 0){
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
    function pickWinner() public {
        uint256 currentDrawId = draw.drawId();
        (, bool currentDrawIsOpen, , uint256 currentDrawEndTime, , , ) = draw.draws(currentDrawId);

        /* require(block.timestamp >= currentDrawEndTime,"Draw endtime still not reached"); */
        require(currentDrawIsOpen, "Draw already closed");
        require(ticket.totalSupply() != 0, "There has been no participation during this draw");

        uint256 totalDeposit = ticket.totalSupply();
        uint256 prize = aToken.balanceOf(address(this)) - totalDeposit;
        require(prize > 0, "There is no winning prize for this draw");

        draw.updatePrize(prize);
        draw.updateDeposit(totalDeposit);
        draw.closeDraw();
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

    /**
     * @notice get draw address
     */
    function getDrawAddress() public view returns (address) {
        return address(draw);
    }

    /**
     * @notice get draw address
     */
    function getTimeLeft() public view returns (uint256) {
        return draw.timeLeft();
    }

    function mintTicket(address _minter, uint256 _amount) external {
        require(msg.sender == address(this) || msg.sender == address(draw), "You cannot mint tickets!");
        ticket.mint(_minter, _amount);
    }
}
