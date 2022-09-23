export const PoolABI = [
    "DrawController public immutable draw",
    "IERC20 immutable usdc",
    "PremiumPoolTicket public immutable ticket",
    "ILendingPool immutable aPool",
    "IAToken immutable aToken",

    "mapping(address => uint256) public userIndex",
    "uint256 public usersCount",
    "address[] public users",
    "mapping(address => uint256) public userDepositedUsdc",
    "uint256 public usdcDeposit",
    "uint256 public prize",

    "event Deposit(address user, uint256 usdcAmount)",
    "event Withdraw(address user, uint256 usdcAmount)",

    "constructor(address _usdc, address _aPool, address _aToken, address vrfCoordinator, address _link, uint64 _subscriptionId, bytes32 _keyhash)",

    "function deposit(uint256 _usdcAmount) public",
    "function depositToAave(uint256 _usdcAmount) private",
    "function withdraw(uint256 _usdcAmount) public",
    "function withdrawFromAave(uint256 _usdcAmount, address _to) private",
    "function pickWinner() public",
    "function createNewDraw() public onlyOwner",
    "function getUsers() public view returns (address[] memory)",
    "function updateUsdcDeposit(uint256 _usdcDeposit) public",
    "function updateUserDepositedUsdc(address _user, uint256 _usdcDeposit) public",
    "function mintTicket(address _minter, uint256 _amount) external"
];