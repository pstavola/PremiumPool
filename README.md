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
	c) Explore the following information of the draw page:  
	
		1.  Draw countdown
		2.  Network selected
		3.  Deposit amount
		4.  Withdraw button

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

		1. An ERC20 standard token.



## Workflow visual


![Disegno senza titolo](https://user-images.githubusercontent.com/8236762/192167895-7acd6cb7-b421-4e51-b62b-a722a6d3a774.jpg)  

# Deployment  
  
Contract deployed and verified on [Görli Testnet](https://goerli.etherscan.io/address/0xbacb905c1ca6d033ecde8b6fe068412090ff64b1#code)    
Contract deployed and verified on [Polygon Mainnet](https://polygonscan.com/address/0x18e7f6638c2e0ac3d8600a5ddfde7d466fa02784#code)  
[Front-end App](https://premium-pool.vercel.app/)  

# Instructions for local installation and tests    
  
1. Clone the repository  

		git clone https://github.com/pstavola/PremiumPool.git

2. Install dependencies  

		yarn install

3. Install Foundry dependencies  

		forge init --force --no-commit  
		forge install openzeppelin/openzeppelin-contracts --no-commit  
		forge install smartcontractkit/chainlink --no-commit 
		forge install foundry-rs/forge-std --no-commit 

4. Run Foundry tests  

		forge test -vv  

# Instructions for UI testing  

Draw is triggered automatically every 24 hours via ChainLink Keepers. For the sake of testing I removed the hard constraint about respecting draw end-time and I added a button to invoke PickWinner function.  
  
[Faucet for Görli USDC](https://staging.aave.com/reserve-overview/?underlyingAsset=0x9fd21be27a2b059a288229361e2fa632d8d2d074&marketName=proto_goerli)  
  

These are the steps to follow to use the app:  
  
	a) Access the Front-end App  
	b) Connect Metamask Account  
	c) Approve $USDC spending by PremiumPool contract  
	d) Deposit $USDC  
	e) (Optional) Withdraw $USDC  
	f) Click "Pick a Winner" or wait for draw end-time.  