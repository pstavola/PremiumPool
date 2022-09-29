// pages/index.tsx
import React, { useEffect, useState } from 'react'
import type { NextPage } from 'next'
import Head from 'next/head'
import NextLink from "next/link"
import { VStack, Heading, Box } from "@chakra-ui/layout"
import { Text, Button, Link } from '@chakra-ui/react'
import {ethers} from "ethers"
import Web3Modal from 'web3modal'
import WalletConnectProvider from '../node_modules/@walletconnect/web3-provider'
// @ts-ignore
import ReadContract from './components/ReadContract.tsx'
// @ts-ignore
import Deposit from './components/Deposit.tsx'
// @ts-ignore
import Withdraw from './components/Withdraw.tsx'
// @ts-ignore
import USDC from './components/USDC.tsx'
// @ts-ignore
import {PoolABI as abi} from './abi/PoolABI.tsx'
// @ts-ignore
import {ERC20ABI as erc20abi} from './abi/ERC20ABI.tsx'
import {CONTRACT, INFURA_ID} from '../config'

declare let window:any

let chainname, currency, contractAddress, contractTicket, contractUsdcaddress, contractLendingController, blockExplorer;

const Home: NextPage = () => {
    const [balance, setBalance] = useState<string | undefined>()
    const [currentAccount, setCurrentAccount] = useState<string | undefined>()
    const [chainId, setChainId] = useState<number | undefined>()
    const [userDeposit, setUserDeposited]=useState<string>()

    /* web3Modal configuration for enabling wallet access */
    async function getWeb3Modal() {
        const web3Modal = new Web3Modal({
            cacheProvider: false,
            providerOptions: {
                walletconnect: {
                package: WalletConnectProvider,
                options: { 
                    infuraId: INFURA_ID
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
            
            provider.getNetwork().then((result)=>{
                setChainId(result.chainId)
                console.log(result.chainId);
                setContractVar(result.name, result.chainId, accounts[0]);
            })
        } catch (err) {
            console.log('error:', err)
        }
    }

    async function disconnect() {
        try {
            const web3Modal = await getWeb3Modal()
            await web3Modal.clearCachedProvider();
            console.log("onClickDisConnect")
            setBalance(undefined)
            setCurrentAccount(undefined)
        } catch (err) {
            console.log('error:', err)
        }
    }

    function setContractVar(chain:string, chainId:number, account:string) {
        const network = CONTRACT(chainId);
        chainname = network.name;
        currency = network.currency;
        contractAddress = network.contractAddress;
        contractTicket = network.contractTicket;
        contractUsdcaddress = network.contractUsdcaddress;
        contractLendingController = network.contractLendingController;
        blockExplorer = network.blockExplorer;
        setCurrentAccount(account)
    }

    useEffect(() => {
        if(!currentAccount || !ethers.utils.isAddress(currentAccount)) return
        if(!window.ethereum) return

        window.ethereum.on('chainChanged', () => {
            window.location.reload();
        })
        window.ethereum.on('accountsChanged', () => {
            changeAccount()
        })

        getInfo();

        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const pool = new ethers.Contract(contractAddress, abi, provider);

        // listen for changes on an Ethereum address
        console.log(`listening for Transfer...`)

        const myDeposit = pool.filters.Deposit(currentAccount, null)
        provider.on(myDeposit, (from, to, amount, event) => {
            console.log('My Deposit', { from, to, amount, event })
            queryUserDeposit(window)
        })

        const myWithdraw = pool.filters.Withdraw(currentAccount, null)
        provider.on(myWithdraw, (from, to, amount, event) => {
            console.log('My Withdraw', { from, to, amount, event })
            queryUserDeposit(window)
        })

        // remove listener when the component is unmounted
        return () => {
            provider.removeAllListeners(myDeposit)
            provider.removeAllListeners(myWithdraw)
        }   
    },[currentAccount])

    async function getInfo() {
        const provider = new ethers.providers.Web3Provider(window.ethereum)

        provider.getNetwork().then((result)=>{
            setChainId(result.chainId)
            setContractVar(result.name, result.chainId, currentAccount);
        })

        provider.getBalance(currentAccount!).then((result)=>{
            setBalance(ethers.utils.formatEther(result))
        })

        queryUserDeposit(window)
    }

    async function changeAccount() {
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const accounts = await provider.listAccounts()
        setCurrentAccount(accounts[0])
    }

    async function queryUserDeposit(window:any){
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const ticket = new ethers.Contract(contractTicket, erc20abi, provider)

        ticket.balanceOf(currentAccount).then((result:string)=>{
            setUserDeposited(ethers.utils.formatUnits(result, 6))
        })//.catch((err)=>message.error(err.error.data.message, 10000))
    }

    return (
        <>
        <Head>
            <title>PremiumPool</title>
        </Head>
        <VStack color='purple'>
            <Heading as="h3"  my={4} color='purple'>Deposit now to have a chance to win!</Heading>
            <Box w='100%' my={4}>
            {currentAccount? 
                <Button type="button" w='100%' color='red' onClick={disconnect}>
                        ⏏️ Disconnect
                </Button>
                : <Button type="button" w='100%' color='red' onClick={connect}>
                        🔗 Connect MetaMask
                </Button>
            }
            </Box>
        </VStack>
        {currentAccount?
            <VStack color='purple'>
                <Box  my={4} p={4} w='100%' borderWidth="1px" borderRadius="lg">
                    <Heading my={4}  fontSize='xl'>
                        <Link color='purple.500' href={blockExplorer + "address/" + currentAccount}>
                            Account {currentAccount}
                        </Link>
                    </Heading>
                    <Text>${currency} Balance: {balance}</Text>
                    <Text>Chain name: {chainname}</Text>
                    <Text>Chain Id: {chainId}</Text>
                    <USDC 
                        currentAccount={currentAccount} 
                        contractUsdcaddress = {contractUsdcaddress}
                    />
                    <Text><b>Your $USDC PremiumPool deposit</b>: {userDeposit}</Text>
                    <Deposit 
                        currentAccount= {currentAccount} 
                        contractAddress = {contractAddress} 
                        contractUsdcaddress = {contractUsdcaddress} 
                        contractLendingController = {contractLendingController}
                    />
                    <Withdraw 
                        currentAccount= {currentAccount} 
                        contractAddress = {contractAddress}
                    />
                </Box>
                <Box  mb={0} p={4} w='100%' borderWidth="1px" borderRadius="lg">
                    <Heading my={4}  fontSize='xl'>PremiumPool Info</Heading>
                    <ReadContract 
                        currentAccount= {currentAccount} 
                        contractAddress = {contractAddress} 
                        contractTicket = {contractTicket}
                    />
                </Box>
            </VStack>
            :<></>
        }
        </>
    )
}

export default Home