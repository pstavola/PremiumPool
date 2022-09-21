// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PremiumPool.sol";
import "../src/DrawController.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PremiumPoolTest is Test {

    PremiumPool public pool;
    DrawController public draw;
    uint256 forkId;
    address usdc = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address aPool = address(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    address aToken = address(0xBcca60bB61934080951369a648Fb03DF4F96263C);
    address vrfCoordinator = address(0xf0d54349aDdcf704F77AE15b96510dEA15cb7952);
    address link = address(0x514910771AF9Ca656af840dff83E8264EcF986CA);
    bytes32 keyhash = bytes32(0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445);
    uint256 fee = 2 * (10**18);
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");
    IERC20 public usdcInstance = IERC20(usdc);

    function setUp() public {
        forkId = vm.createSelectFork("https://mainnet.infura.io/v3/1fc7c7c3701c4083b769e561ae251f9a");
        pool = new PremiumPool(usdc, aPool, aToken, vrfCoordinator, link, keyhash, fee);
        draw = pool.draw();
        pool.createNewDraw();
        deal(address(link), address(draw), 2 * (10**18));
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
        vm.selectFork(forkId);
        address[] memory users = pool.getUsers();
        assertEq(users.length, 0);

        uint256 currentDrawId = draw.drawId();
        (uint256 drawId, , , , , , ) = draw.draws(currentDrawId);
        assertEq(drawId, 1);
    }

    // b. The deployed address is set to the owner.
    function testOwner() public {
        assertEq(pool.owner(), address(this));
    }

    // c. Cannot deposit less then 100 USDC.
    function testCannotDepositLessThan100USDC(uint256 _usdcAmount) public {
        _usdcAmount = bound(_usdcAmount, 1, 99 * (10**18));
        vm.prank(alice);
        vm.expectRevert(abi.encodePacked("minimum deposit is 100 $USDC"));
        pool.deposit(_usdcAmount);
    }

    // d. Cannot withdraw more than deposited.
    function testCannotWithdrawMoreThanDeposited(uint256 _usdcAmount) public {
        _usdcAmount = bound(_usdcAmount, 100 * (10**18)+1, 1000 * (10**18));
        vm.startPrank(alice);
        pool.deposit(_usdcAmount-1);
        vm.expectRevert(abi.encodePacked("You cannot withdraw more than deposited!"));
        pool.withdraw(_usdcAmount);
        vm.stopPrank();
    }

    // e. Cannot pick a winner before endtime is reached.
    function testCannotCloseBeforeEndtime() public {
        vm.expectRevert(abi.encodePacked("Draw endtime still not reached"));
        pool.pickWinner();
    }

    // f. Cannot pick a winner if there are no partecipants.
    function testCannotCloseWithtoutPartecipants() public {
        vm.expectRevert(abi.encodePacked("There has been no participation during this draw"));
        vm.warp(block.timestamp + 24 hours);
        pool.pickWinner();
    }

    // g. Cannot pick a winner if there is no winning prize
    function testCannotCloseWithoutPrize() public {
        vm.warp(block.timestamp + 24 hours);
        vm.prank(alice);
        pool.deposit(100 * (10**18));
        vm.expectRevert(abi.encodePacked("There is no winning prize for this draw"));
        pool.pickWinner();
    }

    // h. Cannot pick a winner if draw is already closed.
    function testCannotAlreadyClosed() public {
        vm.prank(alice);
        pool.deposit(100 * (10**18));
        vm.warp(block.timestamp + 24 hours);
        pool.pickWinner();
        vm.expectRevert(abi.encodePacked("Draw already closed"));
        pool.pickWinner();
    }
}