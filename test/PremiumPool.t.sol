// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import "../src/PremiumPool.sol";
import "../src/DrawController.sol";
import "../src/interfaces/IAToken.sol";
import "../src/Ticket.sol";

contract PremiumPoolTest is Test {
    PremiumPool public pool;
    DrawController public draw;
    PremiumPoolTicket public ticket;
    VRFCoordinatorV2Mock public vrfCoordinator;
    uint256 forkId;
    address usdc = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address aPool = address(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    address aToken = address(0xBcca60bB61934080951369a648Fb03DF4F96263C);
    address link = address(0x514910771AF9Ca656af840dff83E8264EcF986CA);
    //address vrfCoordinator = address(0xf0d54349aDdcf704F77AE15b96510dEA15cb7952);
    uint64 subscriptionId = 1;
    bytes32 keyhash = bytes32(0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445);
    IERC20 public usdcInstance = IERC20(usdc);
    IAToken public aTokenInstance = IAToken(aToken);
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");

    function setUp() public {
        forkId = vm.createSelectFork("https://mainnet.infura.io/v3/1fc7c7c3701c4083b769e561ae251f9a");
        vrfCoordinator = new VRFCoordinatorV2Mock(0, 0);
        vrfCoordinator.createSubscription();
        vrfCoordinator.fundSubscription(1, 7 ether);
        pool = new PremiumPool(usdc, aPool, aToken, address(vrfCoordinator), link, subscriptionId, keyhash);
        draw = pool.draw();
        vrfCoordinator.addConsumer(subscriptionId, address(draw));
        ticket = pool.ticket();
        pool.createNewDraw();
        deal(address(usdc), alice, 10000 * (10**18));
        deal(address(usdc), bob, 10000 * (10**18));
        deal(address(usdc), charlie, 10000 * (10**18));
        vm.prank(alice);
        usdcInstance.approve(address(pool), 10000 * (10**18));
        vm.prank(bob);
        usdcInstance.approve(address(pool), 10000 * (10**18));
        vm.prank(charlie);
        usdcInstance.approve(address(pool), 10000 * (10**18));
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

    // d. Cannot deposit less then 100 USDC.
    function testCannotDepositLessThan100USDC(uint256 _usdcAmount) public {
        _usdcAmount = bound(_usdcAmount, 1, 99 * (10**18));
        vm.prank(alice);
        vm.expectRevert(abi.encodePacked("minimum deposit is 100 $USDC"));
        pool.deposit(_usdcAmount);
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

        assertEq(pool.usersCount(), 3);
        assertEq(pool.usdcDeposit(), _aliceAmount+_bobAmount+_charlieAmount);

        assertEq(pool.userIndex(alice), 0);
        assertEq(pool.users(0), alice);
        assertEq(pool.userDepositedUsdc(alice), _aliceAmount);
        assertEq(usdcInstance.balanceOf(alice), aliceBalance - _aliceAmount);
        assertEq(ticket.balanceOf(alice), _aliceAmount);

        assertEq(pool.userIndex(bob), 1);
        assertEq(pool.users(1), bob);
        assertEq(pool.userDepositedUsdc(bob), _bobAmount);
        assertEq(usdcInstance.balanceOf(bob), bobBalance - _bobAmount);
        assertEq(ticket.balanceOf(bob), _bobAmount);

        assertEq(pool.userIndex(charlie), 2);
        assertEq(pool.users(2), charlie);
        assertEq(pool.userDepositedUsdc(charlie), _charlieAmount);
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

        assertEq(pool.usersCount(), 2);
        assertEq(pool.usdcDeposit(), _bobAmount+_charlieAmount);

        assertEq(pool.userIndex(alice), 0);
        assertEq(pool.users(0), address(0));
        assertEq(pool.userDepositedUsdc(alice), 0);
        assertEq(usdcInstance.balanceOf(alice), aliceBalance);
        assertEq(ticket.balanceOf(alice), 0);

        //assertEq(aTokenInstance.balanceOf(address(pool)), _bobAmount+_charlieAmount);
    }

    // h. Cannot pick a winner before endtime is reached.
    function testCannotCloseBeforeEndtime() public {
        vm.expectRevert(abi.encodePacked("Draw endtime still not reached"));
        pool.pickWinner();
    }

    // i. Cannot pick a winner if there are no partecipants.
    function testCannotCloseWithtoutPartecipants() public {
        vm.expectRevert(abi.encodePacked("There has been no participation during this draw"));
        skip(24 hours);
        pool.pickWinner();
    }

    // j. Cannot pick a winner if there is no winning prize
    function testCannotCloseWithoutPrize() public {
        skip(24 hours);
        vm.prank(alice);
        pool.deposit(100 * (10**18));
        vm.expectRevert(abi.encodePacked("There is no winning prize for this draw"));
        pool.pickWinner();
    }

    // k. Cannot pick a winner if draw is already closed.
    function testCannotAlreadyClosed() public {
        vm.prank(alice);
        pool.deposit(100 * (10**18));
        skip(24 hours);
        pool.pickWinner();
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
        (, bool currentDrawIsOpen, , , uint256 currentDrawPrize, uint256 currentDrawDeposit, ) = draw.draws(currentDrawId);

        uint256 expectedPrize = aTokenInstance.balanceOf(address(pool)) - pool.usdcDeposit();

        assertEq(currentDrawPrize, expectedPrize);
        assertEq(currentDrawDeposit, pool.usdcDeposit());
        assertEq(currentDrawIsOpen, false);

        uint256 aliceBalance = ticket.balanceOf(alice);
        uint256 bobBalance = ticket.balanceOf(bob);
        uint256 charlieBalance = ticket.balanceOf(charlie);

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
}