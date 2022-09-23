export const DrawControllerABI = [
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
    "function fundVRFSubscription(uint96 amount) public",
    "function getCurrentDrawEndtime() public view returns (uint256)"
];