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
import "./PremiumPoolStorage.sol";

/**
 * @title PremiumPool
 * @author Patrizio Stavola
 * @notice Main PremiumPool contract responsible for managing deposits and withdrawals (pool activities) and entry point for end of draws updates and initial checks
 * @dev state variables are stored with contract PremiumPoolStorage which is inherited by PremiumPool contract
*/
contract PremiumPool is
    Ownable, PremiumPoolStorage
{
    /* ========== EVENTS ========== */

    event Deposit(address indexed user, uint256 usdcAmount);
    event Withdraw(address indexed user, uint256 usdcAmount);
    
    /* ========== CONSTRUCTOR ========== */

    constructor(address _usdc, address _aPoolAddrProvider, address _aToken, address vrfCoordinator, address _link, uint64 _subscriptionId, bytes32 _keyhash) 
        PremiumPoolStorage(_usdc, _aPoolAddrProvider, _aToken, vrfCoordinator, _link, _subscriptionId, _keyhash) {}

    /* ========== FUNCTIONS ========== */

    /**
     * @notice allows users to deposit $USDC. Users must manually approve transfer by contract beforehand
     * @param _usdcAmount amount of tokens to deposit
    */
    function deposit(uint256 _usdcAmount) public {
        if(userIndex[msg.sender] == 0) {
            userIndex[msg.sender] = users.length;
            users.push(msg.sender);
        }

        lending.deposit(msg.sender, _usdcAmount, address(usdc), address(aPool));
       
        (bool success, ) = address(this).call(abi.encodeWithSignature("mintTicket(address,uint256)", msg.sender, _usdcAmount));
        require(success);

        emit Deposit(msg.sender, _usdcAmount);
    }

    /**
     * @notice allows users to withdraw $USDC.
     * @param _usdcAmount amount of tokens to withdraw
    */
    function withdraw(uint256 _usdcAmount) public {
        require(ticket.balanceOf(msg.sender) >= _usdcAmount, "You cannot withdraw more than deposited!");

        lending.withdraw(msg.sender, _usdcAmount, address(usdc), address(aToken), address(aPool));
        ticket.burn(msg.sender, _usdcAmount);

        if(ticket.balanceOf(msg.sender) == 0){
            delete users[userIndex[msg.sender]];
            userIndex[msg.sender] = 0;
        }

        emit Withdraw(msg.sender, _usdcAmount);
    }

    /**
     * @notice checks if it is allowed to close the draw, set prize and total deposit for current drwa, close it and create a new draw.
    */
    function pickWinner() public {
        uint256 currentDrawId = draw.drawId();
        (, bool currentDrawIsOpen, , uint256 currentDrawEndTime, , , ) = draw.draws(currentDrawId);

        /* require(block.timestamp >= currentDrawEndTime,"Draw endtime still not reached"); */
        require(currentDrawIsOpen, "Draw already closed");
        require(ticket.totalSupply() != 0, "There has been no participation during this draw");

        uint256 totalDeposit = ticket.totalSupply();
        require(aToken.balanceOf(address(lending))>totalDeposit, "There is no winning prize for this draw");
        uint256 prize = aToken.balanceOf(address(lending)) - totalDeposit;

        draw.updatePrize(prize);
        draw.updateDeposit(totalDeposit);
        draw.closeDraw();
        createNewDraw();
    }

    /**
     * @notice create a new draw by invoking Draw Controller function
    */
    function createNewDraw() public onlyOwner {
        draw.createDraw();
    }

    /**
     * @notice get list of all users partecipating to the draw
     * @return _users array of users
    */
    function getUsers() public view returns (address[] memory _users) {
        _users = users;
    }

    /**
     * @notice get time left to next draw by invoking Draw Controller function
     * @return _timeleft time left as uint
    */
    function getTimeLeft() public view returns (uint256 _timeleft) {
        _timeleft = draw.timeLeft();
    }

    /**
     * @notice mint new $PPT tokens. Only PremiumPool contract and Draw Controller contracts can mint
     * @param _minter address minting tokens
     * @param _amount amount of tokens to mint
    */
    function mintTicket(address _minter, uint256 _amount) external {
        require(msg.sender == address(this) || msg.sender == address(draw), "You cannot mint tickets!");
        ticket.mint(_minter, _amount);
    }
}
