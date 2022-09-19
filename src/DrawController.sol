// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "./PremiumPool.sol";

/**
 * @title Draw
 * @author patricius
 * @notice Contract to handle draws
 * @dev 
 */
contract DrawController is
    Ownable,
    VRFConsumerBase
{
    struct Draw {
        uint256 drawId;
        bool isOpen;
        uint256 startTime;
        uint256 endTime;
        uint256 prize;
        uint256 usdcDeposit;
        address winner;
    }

    /* ========== GLOBAL VARIABLES ========== */

    PremiumPool immutable pool; // pool instance
    uint256 public constant DRAW_DURATION = 24 hours; //duration of every draw
    uint256 public drawId;
    mapping(uint256 => Draw) public draws;
    bytes32 private keyHash;
    uint256 private fee;

    /* ========== EVENTS ========== */

    event DrawCreated(uint256 drawId, uint256 startTime);
    event CloseDraw(uint256 drawId, uint256 endTime);
    event RandomnessRequested(bytes32 requestId, uint256 drawId, uint256 fee);
    event WinnerElected(uint256 drawId, address winner, uint256 prize);

    /* ========== CONSTRUCTOR ========== */

    constructor(address vrfCoordinator, address link, bytes32 _keyhash, uint256 _fee) VRFConsumerBase(vrfCoordinator, link) {
        keyHash = _keyhash;
        fee = _fee;

        pool = PremiumPool(msg.sender);
    }

    /* ========== FUNCTIONS ========== */

    /**
     * @notice create a new draw. Only the Owner contract can create new draws. drawId counter is increased each new draw created.
     */
    function createDraw() external onlyOwner {
        drawId++;
        Draw memory newDraw = Draw({
            drawId: drawId, 
            isOpen: true, 
            startTime: block.timestamp,
            endTime: block.timestamp + DRAW_DURATION,
            prize: 0,
            usdcDeposit: 0,
            winner: address(0)
        });

        draws[drawId] = newDraw;
        
        emit DrawCreated(newDraw.drawId, newDraw.startTime);
    }

    /**
     * @notice close the draw and request a random number to pick the winner.
     */
    function closeDraw() external onlyOwner {
        Draw storage currentDraw = draws[drawId];
        currentDraw.isOpen = false;
        emit CloseDraw(currentDraw.drawId, currentDraw.endTime);

        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK in contract");
        bytes32 requestId = requestRandomness(keyHash, fee);
        emit RandomnessRequested(requestId, currentDraw.drawId, fee);
    }

    /**
     * @notice fulfillRandomness override.
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        Draw storage currentDraw = draws[drawId];
        address[] memory users = pool.getUsers();
        uint256 rnd = randomness % pool.usdcDeposit();

        for(uint256 i=0; i<users.length; i++) {
            address currentUser = pool.users(i);
            uint256 balance = pool.userDepositedUsdc(currentUser);
            if(rnd < balance) {
                currentDraw.winner = currentUser;
                emit WinnerElected(currentDraw.drawId, currentDraw.winner, currentDraw.prize);
            }
            else{
                rnd -= balance;
            }
        }
    }

    function updatePrize(uint256 _prize) public onlyOwner {
        draws[drawId].prize = _prize;
    }

    function updateDeposit(uint256 _usdcDeposit) public onlyOwner {
        draws[drawId].usdcDeposit = _usdcDeposit;
    }
}