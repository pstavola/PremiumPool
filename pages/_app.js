/* pages/__app.js */
import '../styles/globals.css'
import { useState } from 'react'
import Link from 'next/link'
import { css } from '@emotion/css'
import { ethers } from 'ethers'
import Web3Modal from 'web3modal'
import WalletConnectProvider from '@walletconnect/web3-provider'
import { AccountContext } from '../context.js'
/* import contract address and contract owner address */
import {
  contractAddress, ownerAddress
} from '../config'
import 'easymde/dist/easymde.min.css'

/* import Application Binary Interface (ABI) */
import PremiumPool from '../out/PremiumPool.sol/PremiumPool.json'

function MyApp({ Component}) {
  /* create local state to save account information after signin */
  const [account, setAccount] = useState(null)
  /* web3Modal configuration for enabling wallet access */
  async function getWeb3Modal() {
    const web3Modal = new Web3Modal({
      cacheProvider: false,
      providerOptions: {
        walletconnect: {
          package: WalletConnectProvider,
          options: { 
            infuraId: "your-infura-id"
          },
        },
      },
    })
    return web3Modal
  }

  /* the connect function uses web3 modal to connect to the user's wallet */
  async function connect() {
    try {
      const web3Modal = await getWeb3Modal()
      const connection = await web3Modal.connect()
      const provider = new ethers.providers.Web3Provider(connection)
      const accounts = await provider.listAccounts()
      setAccount(accounts[0])
    } catch (err) {
      console.log('error:', err)
    }
  }

  return (
    <div>
      <nav className={nav}>
        <div className={header}>
          <Link href="/">
            <a>
              <img
                src='/logo.svg'
                alt="React Logo"
                style={{ width: '50px' }}
              />
            </a>
          </Link>
          <Link href="/">
            <a>
              <div className={titleContainer}>
                <h2 className={title}>PremiumPool</h2>
                {/* <p className={description}>WEB3</p> */}
              </div>
            </a>
          </Link>
          {
            !account && (
              <div className={buttonContainer}>
                <button className={buttonStyle} onClick={connect}>Connect</button>
              </div>
            )
          }
          {
            account && <p className={accountInfo}>{account}</p>
          }
        </div>
      </nav>
      <div className={container}>
        {/* <form className={title} action="/send-data-here" method="post">
          <label for="first">First name:</label>
          <input type="text" id="first" name="first" />
          <label for="last">Last name:</label>
          <input type="text" id="last" name="last" />
          <button type="submit">Submit</button>
        </form> */}
        <div style={{ padding: 8, marginTop: 32 }}>
          <div>PremiumPool Contract:</div>
          <a className={description} href={"https://etherscan.io/address/" + contractAddress}>{contractAddress}</a>
        </div>

        <div style={{ padding: 8, marginTop: 32 }}>
          <div>⏳ Time left until next draw:</div>
          {/* {timeLeft && humanizeDuration(timeLeft.toNumber() * 1000)} */}
        </div>

        <div style={{ padding: 8 }}>
          <div>Total $USDC Deposit:</div>
          {/* <Balance balance={stakerContractBalance} fontSize={64} />/<Balance balance={threshold} fontSize={64} /> */}
        </div>

        <div style={{ padding: 8 }}>
          <div>Your $USDC deposit:</div>
          {/* <Balance balance={balanceStaked} fontSize={64} /> */}
        </div>

        <div style={{ padding: 8 }}>
          <button className={buttonStyle}
            type={"default"}
            /* onClick={() => {
              tx(writeContracts.Staker.execute());
            }} */
          >
            🚀 🎖 👩‍🚀 Pick Winner! 🎉 🍾 🔥
          </button>
        </div>

        <div style={{ padding: 8 }}>
          <button className={buttonStyle}
            type={"default"}
            /* onClick={() => {
              tx(writeContracts.Staker.withdraw());
            }} */
          >
            ⬆️ Withdraw
          </button>
        </div>

        <div style={{ padding: 8 }}>
          <button className={buttonStyle}
            /*type={balanceStaked ? "success" : "primary"}
             onClick={() => {
              tx(writeContracts.Staker.stake({ value: ethers.utils.parseEther("0.5") }));
            }} */
          >
            ⬇️ Deposit
          </button>
        </div>
      </div>
    </div>
  )
}

const accountInfo = css`
  width: 100%;
  display: flex;
  flex: 1;
  justify-content: flex-end;
  font-size: 12px;
  color: #999999;
`

const container = css`
  padding: 40px;
  background-color: #fafafa;
  text-align: center;
  color: #999999;
`

const linkContainer = css`
  padding: 30px 60px;
  background-color: #fafafa;
`

const nav = css`
  background-color: white;
`

const header = css`
  display: flex;
  border-bottom: 1px solid rgba(0, 0, 0, .075);
  padding: 20px 30px;
`

const description = css`
  margin: 0;
  color: #999999;
`

const titleContainer = css`
  display: flex;
  flex-direction: column;
  padding-left: 15px;
`

const title = css`
  margin-left: 30px;
  font-weight: 500;
  margin: 0;
  color: #999999;
`

const buttonContainer = css`
  width: 100%;
  display: flex;
  flex: 1;
  justify-content: flex-end;
`

const buttonStyle = css`
  background-color: #fafafa;
  outline: none;
  border: none;
  font-size: 18px;
  padding: 16px 70px;
  border-radius: 15px;
  cursor: pointer;
  box-shadow: 7px 7px rgba(0, 0, 0, .1);
  color: #999999;
`

const link = css`
  margin: 0px 40px 0px 0px;
  font-size: 16px;
  font-weight: 400;
`

export default MyApp