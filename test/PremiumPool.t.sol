// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PremiumPool.sol";
import "../src/DrawController.sol";

contract PremiumPoolTest is Test {

    PremiumPool public pool;
    DrawController public draw;

    function setUp() public {
        address usdc = makeAddr("usdc");
        address aPool = makeAddr("aPool");
        address aToken = makeAddr("aToken");
        address vrfCoordinator = makeAddr("vrfCoordinator");
        address link = makeAddr("link");
        bytes32 keyhash = "keyhash";
        uint256 fee = 100000000000000000;

        pool = new PremiumPool(usdc, aPool, aToken, vrfCoordinator, link, keyhash, fee);
        draw = pool.draw();
        pool.createNewDraw();
    }

    // a. The contract is deployed successfully.
    function testCreateContract() public {
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

    // c. Cannot deposit less then 99 USDC.
    function testCannotDepositLessThan100USDC(uint256 _usdcAmount) public {
        vm.expectRevert(abi.encodePacked("minimum deposit is 100 $USDC"));

        _usdcAmount = bound(_usdcAmount, 1, 99 * (10**18));

        pool.deposit(_usdcAmount);
    }

    // d. Cannot withdraw more than deposited.
    /* function testCannotWithdrawMoreThanDeposited(uint256 _usdcAmount) public {
        vm.expectRevert(abi.encodePacked("You cannot withdraw more than deposited!!"));

        _usdcAmount = bound(_usdcAmount, 100 * (10**18)+1, 1000 * (10**18));

        pool.deposit(_usdcAmount-1);
        pool.withdraw(_usdcAmount);
    } */

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
    /* function testCannotCloseWithtoutPrize() public {
        vm.expectRevert(abi.encodePacked("There is no winning prize for this draw"));

        address alice = makeAddr("alice");
        hoax(alice);
        pool.deposit(100 * (10**18));

        vm.warp(block.timestamp + 24 hours);
        vm.prank(pool.owner());
        pool.pickWinner();
    } */

    // h. Cannot pick a winner if draw is already closed.
    /* function testCannotAlreadyClosed() public {
        vm.expectRevert(abi.encodePacked("Draw already closed"));

        address alice = makeAddr("alice");
        hoax(alice);
        pool.deposit(100 * (10**18));

        vm.warp(block.timestamp + 24 hours);
        vm.prank(pool.owner());
        pool.pickWinner();
        pool.pickWinner();
    } */
}
