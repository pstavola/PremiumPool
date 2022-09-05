# PremiumPool

**Project:** PremiumPool
**Author:** Patrizio Stavola
**Date:** 05 September, 2022


# Overview

A prize savings protocol enabling investors to win by saving. Prizes are generated on the interest earned on deposited funds.

When a $USDC deposit is made into PremiumPool that deposit is automatically routed to Aave to begin earning interest. The deposits themselves attract no interest and are redeemable at par (face value) at any time. The attraction for an investor is that, each day, a draw takes place and, should an investor be chosen as winner, then the investor will be awarded a prize equivalent to the interest payable on the entire pool for that day. If an investor wins a prize, that prize is not redeemed but remains 'in the pool' for all forthcoming draws (at least until redeemed).

PremiumPool is a non-custodial protocol. That means no one has the ability to control the funds deposited. All deposits and withdraws are conducted automatically by the smart contracts making up the PremiumPool protocol. Being powered by Ethereum, everything is transparent and trustless.

## Deliverables

1.  Web App: A user-friendly web application that allows users to.

	a) Connect their wallets.
	b) Deposit $USDC to be eligible for the next draw.
	c) Browse all the past draws’ winners.
	d) Explore the following information of the draw page
	
		1.  Draw countdown
		2.  Network selected
		3.  Prize APR
		4.  Daily winning odds
		5.  Deposit amount
		6.  Withdraw button

2. Smart Contracts: A set of smart-contract to perform everything on-chain to maintain transparency.

	a) **PremiumPool**

		1. A mapping to keep track of every investors’ deposit.
		2. Deposit function that allows investors and receive “Ticket” tokens in exchange at a 1:1 to have a claim for the next draw. Contextually it also deposits funds to Aave $USDC reserve pool.
		3. Withdraw function that allows investors to redeem their deposits at any time in exchange of their Ticket tokens.

	b) **Draw**

		1. A mapping to keep track of every draws completed. The “Draw” struct to store: draw startTime, draw endTime, deposit amount, prize amount, winner address..
		2. Create a new draw pool with startTime and countdown.
		3. Draw function that relies on ChainLink VRF (Verifiably Random Function) for choosing winners.

	c) **Ticket**

		1. An extension of the standard ERC20 interface with time-weighted average balance functionality.
		2. A mapping to keep track of token holders TWAB for each account.
		3. Average balance between two timestamps calculation function.



## Workflow visual




