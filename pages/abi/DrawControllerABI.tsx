export const Draw = "(uint256 drawId, bool isOpen, uint256 startTime, uint256 endTime, uint256 prize, uint256 usdcDeposit, address winner,)";

export const PoolABI = [
    "PremiumPool immutable pool",
    "PremiumPoolTicket poolTicket",
    "uint256 public constant DRAW_DURATION",
    "uint256 public drawId",
    "mapping(uint256 => ${Draw}) public draws",
    "VRFCoordinatorV2Interface immutable coordinator",
    "uint64 immutable subscriptionId",
    "bytes32 immutable keyHash",
    "uint256[] public randomWords",
    "uint256 public requestId",
    "LinkTokenInterface immutable link",

    "event DrawCreated(uint256 drawId, uint256 startTime)",
    "event CloseDraw(uint256 drawId, uint256 endTime)",
    "event RandomnessRequested(uint256 requestId, uint256 drawId)",
    "event WinnerElected(uint256 drawId, address winner, uint256 prize)",

    "constructor(address vrfCoordinator, address _link, uint64 _subscriptionId, bytes32 _keyhash) VRFConsumerBaseV2(vrfCoordinator)",
    "function createDraw() external onlyOwner",
    "function closeDraw() external onlyOwner",
    "function fulfillRandomWords(uint256, uint256[] memory _randomWords) internal override",
    "function updatePrize(uint256 _prize) public onlyOwner",
    "function updateDeposit(uint256 _usdcDeposit) public onlyOwner",
    "function cancelVRFSubscription() external",
    "function fundVRFSubscription(uint96 amount) public"
];