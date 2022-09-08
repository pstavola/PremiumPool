// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

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
    using Counters for Counters.Counter;

    struct Draw {
        uint256 drawId;
        bool isOpen;
        uint256 startTime;
        uint256 endTime;
        uint256 prize;
        uint256 usdcDeposit;
        address[] participants;
        address winner;
    }

    /* ========== GLOBAL VARIABLES ========== */

    uint256 public constant DRAW_DURATION = 24 hours; //duration of every draw
    Counters.Counter private drawId;
    mapping(uint256 => Draw) private draws;
    mapping(bytes32 => uint256) private drawRandomnessRequest;
    mapping(uint256 => mapping(address => uint256)) ppplayer; //participations per player
    mapping(uint256 => uint256) playersCount;
    bytes32 private keyHash;
    uint256 private fee;

    /* ========== EVENTS ========== */

    event DrawCreated(uint256 drawId, uint256 startTime, uint256 endTime);

     /* ========== CONSTRUCTOR ========== */

    constructor(address vrfCoordinator, address link, bytes32 _keyhash, uint256 _fee) VRFConsumerBase(vrfCoordinator, link) {
        keyHash = _keyhash;
        fee = _fee;
    }

    /* ========== FUNCTIONS ========== */

    /**
     * @notice create a new draw. Only the Owner contract can create new draws. drawId counter is increased each new draw created.
     */
    function createDraw()
        public
        onlyOwner
    {
        Draw memory newDraw = Draw({
            drawId: drawId.current(), 
            isOpen: true, 
            startTime: block.timestamp,
            endTime: block.timestamp + DRAW_DURATION,
            prize: 0,
            usdcDeposit: 0,
            participants: new address[](0),
            winner: address(0)
        });

        draws[drawId.current()] = newDraw;
        drawId.increment();

        emit DrawCreated(newDraw.drawId, newDraw.startTime, newDraw.endTime);
    }


    /**
     * @notice override required by Solidity.
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        
    }
}