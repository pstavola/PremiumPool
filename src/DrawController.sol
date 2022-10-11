// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "./PremiumPool.sol";
import "./Ticket.sol";

/**
 * @title DrawController
 * @author Patrizio Stavola
 * @notice Draw Controller responsible for managing draws (create and close) and to request randomness via Chainlink Verifiable Random Function architecture
 * @dev this contract inherits VRFConsumerBaseV2 to interact with Chainlink VRF
*/
contract DrawController is
    Ownable,
    VRFConsumerBaseV2
{
    ///@notice structure that defines draws
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

    ///@notice constant defining draw duration
    uint256 public constant DRAW_DURATION = 24 hours;
    ///@notice Id counter
    uint256 public drawId;
    ///@notice mapping to store past and current draws
    mapping(uint256 => Draw) public draws;

    ///@notice PremiumPool contract instance
    PremiumPool immutable pool;
    ///@notice $PPT token instance
    PremiumPoolTicket poolTicket;
    ///@notice $LINK token instance
    LinkTokenInterface immutable link;
 
    ///@notice ChainLink VRF v2 parameters
    VRFCoordinatorV2Interface immutable coordinator;
    uint64 immutable subscriptionId;
    bytes32 immutable keyHash;
    uint256[] public randomWords;
    uint256 public requestId;

    /* ========== EVENTS ========== */

    event DrawCreated(uint256 indexed drawId, uint256 startTime);
    event CloseDraw(uint256 indexed drawId, uint256 endTime);
    event RandomnessRequested(uint256 indexed requestId, uint256 indexed drawId);
    event WinnerElected(uint256 indexed drawId, address indexed winner, uint256 prize);

    /* ========== CONSTRUCTOR ========== */

    /**
     * @notice initializing Chainlink VRF, PremiumPool and $LINK token.
     * @param _vrfCoordinator address of Chainlink VRF Coordinator
     * @param _link address of $LINK token
     * @param _subscriptionId Chainlink VRF subscription Id
     * @param _keyhash Chainlink VRF Key Hash
    */
    constructor(address _vrfCoordinator, address _link, uint64 _subscriptionId, bytes32 _keyhash) VRFConsumerBaseV2(_vrfCoordinator) {
        coordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
        keyHash = _keyhash;
        subscriptionId = _subscriptionId;
        pool = PremiumPool(msg.sender);
        link = LinkTokenInterface(_link);
    }

    /* ========== FUNCTIONS ========== */

    /**
     * @notice create a new draw. Only PremiumPool contract can create new draws. drawId counter is increased each new draw created.
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
     * @notice close the draw and request randomness via Chainlink VRF. Only PremiumPool contract can close draws
    */
    function closeDraw() external onlyOwner {
        Draw storage currentDraw = draws[drawId];
        currentDraw.isOpen = false;
        emit CloseDraw(currentDraw.drawId, currentDraw.endTime);

        requestId = coordinator.requestRandomWords(keyHash, subscriptionId, 3, 150000, 1);
        emit RandomnessRequested(requestId, currentDraw.drawId);
    }

    /**
     * @notice VRFConsumerBaseV2 fulfillRandomWords override. It picks a winner by using a roulette selection over a weighted array of partecipants addresses
     * @param _randomWords array of random words provided by Chainlink oracles
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

    /**
     * @notice updates draw prize. Only PremiumPool contract can update
     * @param _prize prize amount
    */
    function updatePrize(uint256 _prize) public onlyOwner {
        draws[drawId].prize = _prize;
    }

    /**
     * @notice updates draw final deposit. Only PremiumPool contract can update
     * @param _usdcDeposit total deposit amount
    */
    function updateDeposit(uint256 _usdcDeposit) public onlyOwner {
        draws[drawId].usdcDeposit = _usdcDeposit;
    }
  
    /**
     * @notice fund Chainlink VRF subscription. Anybody can fund a subscription
     * @param _amount funds to send to subscription
    */
    function fundVRFSubscription(uint96 _amount) public {
        link.transferAndCall(address(coordinator), _amount, abi.encode(subscriptionId));
    }

    /**
     * @notice returns the time left to the deadline of current draw. Used by frontend
     * @return _timeleft time left as uint
    */
    function timeLeft() public view returns(uint256 _timeleft) {
        uint256 deadline = draws[drawId].endTime;
        if (block.timestamp>=deadline)
            _timeleft = 0;
        else
            _timeleft = deadline-block.timestamp;
    }
}
