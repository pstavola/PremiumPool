// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import "../src/PremiumPool.sol";
import "../src/DrawController.sol";
import "../src/interfaces/IAToken.sol";
import "../src/Ticket.sol";
import "../src/LendingController.sol";

contract PremiumPoolTest is Test {
    using stdStorage for StdStorage;
    PremiumPool public pool;
    DrawController public draw;
    PremiumPoolTicket public ticket;
    VRFCoordinatorV2Mock public vrfCoordinator;
    uint256 forkId;
    /** ETHEREUM MAINNET */
    /* address usdc = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address aPoolAddrProv = address(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5);
    address aToken = address(0xBcca60bB61934080951369a648Fb03DF4F96263C);
    address link = address(0x514910771AF9Ca656af840dff83E8264EcF986CA);
    bytes32 keyhash = bytes32(0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef); */
    /** ETHEREUM GOERLI */
    /* address usdc = address(0x07865c6E87B9F70255377e024ace6630C1Eaa37F);
    address aPoolAddrProv = address(0x5E52dEc931FFb32f609681B8438A51c675cc232d);
    address aToken = address(0xBcca60bB61934080951369a648Fb03DF4F96263C);
    address link = address(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
    bytes32 keyhash = bytes32(0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15); */
    /** */
    /** POLYGON MAINNET */
    address usdc = address(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
    address aPoolAddrProv = address(0xd05e3E715d945B59290df0ae8eF85c1BdB684744);
    address aToken = address(0x1a13F4Ca1d028320A707D99520AbFefca3998b7F);
    address link = address(0xb0897686c545045aFc77CF20eC7A532E3120E0F1);
    bytes32 keyhash = bytes32(0x6e099d640cde6de9d40ac749b4b594126b0169747122711109c9985d47751f93);
    /** */
    /** POLYGON MUMBAI */
    /* address usdc = address(0x0FA8781a83E46826621b3BC094Ea2A0212e71B23);
    address aPoolAddrProv = address(0x178113104fEcbcD7fF8669a0150721e231F0FD4B);
    address aToken = address(0x2271e3Fef9e15046d09E1d78a8FF038c691E9Cf9);
    address link = address(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
    bytes32 keyhash = bytes32(0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f); */
    /** */
    uint64 subscriptionId = 1;
    IERC20 public usdcInstance = IERC20(usdc);
    IAToken public aTokenInstance = IAToken(aToken);
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");

    function setUp() public {
        //forkId = vm.createSelectFork("https://mainnet.infura.io/v3/1fc7c7c3701c4083b769e561ae251f9a");
        //forkId = vm.createSelectFork("https://goerli.infura.io/v3/1fc7c7c3701c4083b769e561ae251f9a");
        forkId = vm.createSelectFork("https://polygon-mainnet.infura.io/v3/1fc7c7c3701c4083b769e561ae251f9a");
        //forkId = vm.createSelectFork("https://polygon-mumbai.infura.io/v3/1fc7c7c3701c4083b769e561ae251f9a");
        vrfCoordinator = new VRFCoordinatorV2Mock(0, 0);
        vrfCoordinator.createSubscription();
        vrfCoordinator.fundSubscription(1, 7 ether);
        pool = new PremiumPool(usdc, aPoolAddrProv, aToken, address(vrfCoordinator), link, subscriptionId, keyhash);
        draw = pool.draw();
        vrfCoordinator.addConsumer(subscriptionId, address(draw));
        ticket = pool.ticket();
        pool.createNewDraw();
        deal(address(usdc), alice, 10000 * (10**18));
        deal(address(usdc), bob, 10000 * (10**18));
        deal(address(usdc), charlie, 10000 * (10**18));
        LendingController lendingController = pool.lending();
        vm.prank(alice);
        usdcInstance.approve(address(lendingController), 10000 * (10**18));
        vm.prank(bob);
        usdcInstance.approve(address(lendingController), 10000 * (10**18));
        vm.prank(charlie);
        usdcInstance.approve(address(lendingController), 10000 * (10**18));
    }

    // a. The contract is deployed successfully.
    function testCreateContract() public {
        address[] memory users = pool.getUsers();
        assertEq(users.length, 0);
    }

    // b. Draw has ben created successfully.
    function testCreateDraw() public {
        uint256 currentDrawId = draw.drawId();
        (uint256 drawId, , , , , , ) = draw.draws(currentDrawId);
        assertEq(drawId, 1);
    }

    // c. The deployed address is set to the owner.
    function testOwner() public {
        assertEq(pool.owner(), address(this));
    }

    // e. Can make deposits.
    function testDeposit(uint256 _aliceAmount, uint256 _bobAmount, uint256 _charlieAmount) public {
        _aliceAmount = bound(_aliceAmount, 100 * (10**18), 1000 * (10**18));
        _bobAmount = bound(_bobAmount, 1001 * (10**18), 5000 * (10**18));
        _charlieAmount = bound(_charlieAmount, 5001 * (10**18), 10000 * (10**18));

        uint256 aliceBalance = usdcInstance.balanceOf(alice);
        uint256 bobBalance = usdcInstance.balanceOf(bob);
        uint256 charlieBalance = usdcInstance.balanceOf(charlie);

        vm.prank(alice);
        pool.deposit(_aliceAmount);
        vm.roll(block.number+1);
        vm.prank(bob);
        pool.deposit(_bobAmount);
        vm.roll(block.number+1);
        vm.prank(charlie);
        pool.deposit(_charlieAmount);

        assertEq(ticket.totalSupply(), _aliceAmount+_bobAmount+_charlieAmount);

        assertEq(pool.userIndex(alice), 0);
        assertEq(pool.users(0), alice);
        assertEq(usdcInstance.balanceOf(alice), aliceBalance - _aliceAmount);
        assertEq(ticket.balanceOf(alice), _aliceAmount);

        assertEq(pool.userIndex(bob), 1);
        assertEq(pool.users(1), bob);
        assertEq(usdcInstance.balanceOf(bob), bobBalance - _bobAmount);
        assertEq(ticket.balanceOf(bob), _bobAmount);

        assertEq(pool.userIndex(charlie), 2);
        assertEq(pool.users(2), charlie);
        assertEq(usdcInstance.balanceOf(charlie), charlieBalance - _charlieAmount);
        assertEq(ticket.balanceOf(charlie), _charlieAmount);

        //assertEq(aTokenInstance.balanceOf(address(pool)), _aliceAmount+_bobAmount+_charlieAmount);
    }

    // f. Cannot withdraw more than deposited.
    function testCannotWithdrawMoreThanDeposited(uint256 _usdcAmount) public {
        _usdcAmount = bound(_usdcAmount, 100 * (10**18), 10000 * (10**18));
        vm.startPrank(alice);
        pool.deposit(_usdcAmount);
        vm.expectRevert(abi.encodePacked("You cannot withdraw more than deposited!"));
        pool.withdraw(_usdcAmount+1);
        vm.stopPrank();
    }

    // g. Can withdraw what has been deposited.
    function testWithdraw(uint256 _aliceAmount, uint256 _bobAmount, uint256 _charlieAmount) public {
        _aliceAmount = bound(_aliceAmount, 100 * (10**18), 1000 * (10**18));
        _bobAmount = bound(_bobAmount, 1001 * (10**18), 5000 * (10**18));
        _charlieAmount = bound(_charlieAmount, 5001 * (10**18), 10000 * (10**18));

        uint256 aliceBalance = usdcInstance.balanceOf(alice);

        vm.prank(alice);
        pool.deposit(_aliceAmount);
        vm.roll(block.number+1);
        vm.prank(bob);
        pool.deposit(_bobAmount);
        vm.roll(block.number+1);
        vm.prank(charlie);
        pool.deposit(_charlieAmount);
        vm.roll(block.number+1);
        vm.prank(alice);
        pool.withdraw(_aliceAmount);

        assertEq(ticket.totalSupply(), _bobAmount+_charlieAmount);

        assertEq(pool.userIndex(alice), 0);
        assertEq(pool.users(0), address(0));
        assertEq(usdcInstance.balanceOf(alice), aliceBalance);
        assertEq(ticket.balanceOf(alice), 0);

        //assertEq(aTokenInstance.balanceOf(address(pool)), _bobAmount+_charlieAmount);
    }

    // h. Cannot pick a winner before endtime is reached.
    /* function testCannotCloseBeforeEndtime() public {
        vm.expectRevert(abi.encodePacked("Draw endtime still not reached"));
        pool.pickWinner();
    } */

    // i. Cannot pick a winner if there are no partecipants.
    function testCannotCloseWithtoutPartecipants() public {
        vm.expectRevert(abi.encodePacked("There has been no participation during this draw"));
        skip(24 hours);
        pool.pickWinner();
    }

    // j. Cannot pick a winner if there is no winning prize
    /* function testCannotCloseWithoutPrize() public {
        skip(24 hours);
        vm.prank(alice);
        pool.deposit(100 * (10**18));
        vm.expectRevert(abi.encodePacked("There is no winning prize for this draw"));
        pool.pickWinner();
    } */

    // k. Cannot pick a winner if draw is already closed.
    function testCannotAlreadyClosed() public {
        vm.prank(alice);
        pool.deposit(100 * (10**18));
        skip(24 hours);
        pool.pickWinner();
        uint256 currentDrawId = draw.drawId();
        currentDrawId--;
        // updating drawId in order to point to the previous draw already closed
        stdstore
            .target(address(draw))
            .sig(draw.drawId.selector)
            .checked_write(currentDrawId);
        vm.expectRevert(abi.encodePacked("Draw already closed"));
        pool.pickWinner();
    }

    // l. Can close the draw and pick a winner.
    function testPickWinner(uint256 _aliceAmount, uint256 _bobAmount, uint256 _charlieAmount, uint256 _randomNum) public {
        _aliceAmount = bound(_aliceAmount, 100 * (10**18), 1000 * (10**18));
        _bobAmount = bound(_bobAmount, 1001 * (10**18), 5000 * (10**18));
        _charlieAmount = bound(_charlieAmount, 5001 * (10**18), 10000 * (10**18));

        vm.prank(alice);
        pool.deposit(_aliceAmount);
        vm.roll(block.number+1);
        vm.prank(bob);
        pool.deposit(_bobAmount);
        vm.roll(block.number+1);
        vm.prank(charlie);
        pool.deposit(_charlieAmount);
        vm.roll(block.number+1);
        skip(24 hours);
        pool.pickWinner();

        uint256 currentDrawId = draw.drawId();
        currentDrawId--;
        (, bool currentDrawIsOpen, , , uint256 currentDrawPrize, uint256 currentDrawDeposit, ) = draw.draws(currentDrawId);

        uint256 totalSupply = ticket.totalSupply();
        LendingController lendingController = pool.lending();
        uint256 expectedPrize = aTokenInstance.balanceOf(address(lendingController)) - totalSupply;

        assertEq(currentDrawPrize, expectedPrize);
        assertEq(currentDrawDeposit, totalSupply);
        assertEq(currentDrawIsOpen, false);

        uint256 aliceBalance = ticket.balanceOf(alice);
        uint256 bobBalance = ticket.balanceOf(bob);
        uint256 charlieBalance = ticket.balanceOf(charlie);

        // updating drawId in order to point to the previous draw already closed
        stdstore
            .target(address(draw))
            .sig(draw.drawId.selector)
            .checked_write(currentDrawId);

        uint256[] memory randomWords = new uint256[](1);
        randomWords[0] = _randomNum;
        vm.prank(address(vrfCoordinator));
        draw.rawFulfillRandomWords(1, randomWords);

        (, , , , , , address currentDrawWinner) = draw.draws(currentDrawId);

        assertFalse(currentDrawWinner==address(0));

        if (currentDrawWinner == alice) {
            assertEq(ticket.balanceOf(alice), aliceBalance + currentDrawPrize);
        } else if (currentDrawWinner == bob) {
            assertEq(ticket.balanceOf(bob), bobBalance + currentDrawPrize);
        } else if (currentDrawWinner == charlie) {
            assertEq(ticket.balanceOf(charlie), charlieBalance + currentDrawPrize);
        }
    }

    // m. Ticket can be minted only by owner address (PremiumPool contract).
    function testMintToken(uint256 _usdcAmount) public {
        vm.prank(address(pool));
        ticket.mint(address(pool), _usdcAmount);

        vm.prank(alice);
        vm.expectRevert(abi.encodePacked("Ownable: caller is not the owner"));
        ticket.mint(alice, _usdcAmount);
    }
}