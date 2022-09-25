export const DrawControllerABI = [
    "event DrawCreated(uint256 indexed drawId, uint256 startTime)",
    "event CloseDraw(uint256 indexed drawId, uint256 endTime)",
    "event RandomnessRequested(uint256 indexed requestId, uint256 indexed drawId)",
    "event WinnerElected(uint256 indexed drawId, address indexed winner, uint256 prize)",

    "constructor(address vrfCoordinator, address _link, uint64 _subscriptionId, bytes32 _keyhash)",
    "function createDraw() external onlyOwner",
    "function closeDraw() external onlyOwner",
    "function fulfillRandomWords(uint256, uint256[] memory _randomWords) internal override",
    "function updatePrize(uint256 _prize) public onlyOwner",
    "function updateDeposit(uint256 _usdcDeposit) public onlyOwner",
    "function cancelVRFSubscription() external",
    "function fundVRFSubscription(uint96 amount) public",
    "function timeLeft() public view returns(uint256)"
];