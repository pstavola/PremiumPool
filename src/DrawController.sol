// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "./PremiumPool.sol";
import "./Ticket.sol";

/**
 * @title Draw
 * @author patricius
 * @notice Contract to handle draws
 * @dev 
 */
contract DrawController is
    Ownable,
    VRFConsumerBaseV2
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
    PremiumPoolTicket poolTicket; // ticket instance
    uint256 public constant DRAW_DURATION = 24 hours; //duration of every draw
    uint256 public drawId;
    mapping(uint256 => Draw) public draws;

    /* ChainLink VRF v2 parameters */
    VRFCoordinatorV2Interface immutable coordinator;
    uint64 immutable subscriptionId;
    bytes32 immutable keyHash;
    uint256[] public randomWords;
    uint256 public requestId;
    /* */
    LinkTokenInterface immutable link;

    /* ========== EVENTS ========== */

    event DrawCreated(uint256 indexed drawId, uint256 startTime);
    event CloseDraw(uint256 indexed drawId, uint256 endTime);
    event RandomnessRequested(uint256 indexed requestId, uint256 indexed drawId);
    event WinnerElected(uint256 indexed drawId, address indexed winner, uint256 prize);

    /* ========== CONSTRUCTOR ========== */

    constructor(address vrfCoordinator, address _link, uint64 _subscriptionId, bytes32 _keyhash) VRFConsumerBaseV2(vrfCoordinator) {
        coordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        keyHash = _keyhash;
        subscriptionId = _subscriptionId;
        pool = PremiumPool(msg.sender);
        link = LinkTokenInterface(_link);
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

        requestId = coordinator.requestRandomWords(keyHash, subscriptionId, 3, 150000, 1);
        emit RandomnessRequested(requestId, currentDraw.drawId);
    }

    /**
     * @notice fulfillRandomWords override.
     */
    function fulfillRandomWords(uint256, uint256[] memory _randomWords) internal override {
        randomWords = _randomWords;
        uint256 drawToUpdate = drawId;
        drawToUpdate--;
        Draw storage currentDraw = draws[drawToUpdate];
        address[] memory users = pool.getUsers();
        PremiumPoolTicket ticket = PremiumPoolTicket(address(pool.ticket()));
        uint256 rnd = randomWords[0] % ticket.totalSupply();

        for(uint256 i=0; i<users.length && currentDraw.winner==address(0); i++) {
            address currentUser = pool.users(i);
            uint256 balance = ticket.balanceOf(currentUser);
            if(rnd < balance) {
                currentDraw.winner = currentUser;
                uint256 prize = currentDraw.prize;
                pool.mintTicket(currentUser, prize);
                emit WinnerElected(drawId, currentUser, prize);
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

    function cancelVRFSubscription() external {
        coordinator.cancelSubscription(subscriptionId, msg.sender);
    }
  
    function fundVRFSubscription(uint96 amount) public {
        link.transferAndCall(address(coordinator), amount, abi.encode(subscriptionId));
    }

    /**
     * @notice returns the time left before the deadline to the frontend
     */
    function timeLeft() public view returns(uint256) {
        uint256 deadline = draws[drawId].endTime;
        if (block.timestamp>=deadline)
            return 0;
        else
            return deadline-block.timestamp;
    }
}
