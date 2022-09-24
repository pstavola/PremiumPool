// pages/index.tsx
import React, { ReactNode, useCallback, useEffect, useState } from 'react'
import type { NextPage } from 'next'
import Head from 'next/head'
import NextLink from "next/link"
import { VStack, Heading, Box, LinkOverlay, LinkBox} from "@chakra-ui/layout"
import { Text, Button } from '@chakra-ui/react'
import {ethers} from "ethers"
import Web3Modal from 'web3modal'
import WalletConnectProvider from '@walletconnect/web3-provider'
import { INFURA_ID, NETWORK, NETWORKS } from "../constants";
// @ts-ignore
import ReadContract from './components/ReadContract.tsx'
// @ts-ignore
import Deposit from './components/Deposit.tsx'
// @ts-ignore
import Withdraw from './components/Withdraw.tsx'
// @ts-ignore
import PickWinner from './components/PickWinner.tsx'
// @ts-ignore
import USDC from './components/USDC.tsx'
// @ts-ignore
import Timeleft from './components/Timeleft.tsx'

const targetNetwork = NETWORKS.localhost;
const localProviderUrl = targetNetwork.rpcUrl;
const localProvider = new ethers.providers.StaticJsonRpcProvider(localProviderUrl);
const blockExplorer = targetNetwork.blockExplorer;

declare let window:any

const Home: NextPage = () => {
    const [balance, setBalance] = useState<string | undefined>()
    const [currentAccount, setCurrentAccount] = useState<string | undefined>()
    const [chainId, setChainId] = useState<number | undefined>()
    const [chainname, setChainName] = useState<string | undefined>()

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
            setCurrentAccount(accounts[0])
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

    useEffect(() => {
        async function getInfo() {
            const provider = new ethers.providers.Web3Provider(window.ethereum)
            provider.getBalance(currentAccount!).then((result)=>{
                setBalance(ethers.utils.formatEther(result))
            })
            provider.getNetwork().then((result)=>{
                setChainId(result.chainId)
                setChainName(result.name)
            })
          }
        if(!currentAccount || !ethers.utils.isAddress(currentAccount)) return
        if(!window.ethereum) return
        getInfo();
    },[currentAccount])

    return (
        <>
        <Head>
            <title>PremiumPool</title>
        </Head>

        <Heading as="h3"  my={4}>Deposit now to have a chance to win!</Heading>          
        <VStack>
            <Box w='100%' my={4}>
            {currentAccount? 
                <Button type="button" w='100%' onClick={disconnect}>
                        Disconnect
                </Button>
                : <Button type="button" w='100%' onClick={connect}>
                        Connect MetaMask
                </Button>
            }
            </Box>
            {currentAccount?
                <LinkBox  my={4} p={4} w='100%' borderWidth="1px" borderRadius="lg">
                    <NextLink href={blockExplorer + "address/" + currentAccount} passHref>
                    <LinkOverlay>
                        <Heading my={4}  fontSize='xl'>Account {currentAccount}</Heading>
                        <Text>ETH Balance: {balance}</Text>
                        <USDC addressUsdcContract='0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48' currentAccount={currentAccount}/>
                        <Text>Chain name: {chainname}</Text>
                        <Text>Chain Id: {chainId}</Text>
                    </LinkOverlay>
                    </NextLink>
                </LinkBox>
                :<></>
            }

            {currentAccount?
                <Box  mb={0} p={4} w='100%' borderWidth="1px" borderRadius="lg">
                    <Heading my={4}  fontSize='xl'>PremiumPool Info</Heading>
                    <ReadContract
                        addressContract='0x627b9a657eac8c3463ad17009a424dfe3fdbd0b1'
                        currentAccount={currentAccount}
                    />
                </Box>
                :<></>
            }
            {currentAccount?
                <Box  mb={0} p={4} w='100%' borderWidth="1px" borderRadius="lg">
                    <Heading my={4}  fontSize='xl'>Deposit $USDC</Heading>
                    <Deposit 
                        addressContract='0x627b9a657eac8c3463ad17009a424dfe3fdbd0b1'
                        currentAccount={currentAccount}
                    />
                </Box>
                :<></>
            }
            {currentAccount?
                <Box  mb={0} p={4} w='100%' borderWidth="1px" borderRadius="lg">
                    <Heading my={4}  fontSize='xl'>Withdraw $USDC</Heading>
                    <Withdraw 
                        addressContract='0x627b9a657eac8c3463ad17009a424dfe3fdbd0b1'
                        currentAccount={currentAccount}
                    />
                </Box>
                :<></>
            }
            {currentAccount?
                <Box  mb={0} p={4} w='100%' borderWidth="1px" borderRadius="lg">
                    <Heading my={4}  fontSize='xl'>Timeleft</Heading>
                    <Timeleft
                        addressContract='0x627b9a657eac8c3463ad17009a424dfe3fdbd0b1'
                        currentAccount={currentAccount}
                    />
                </Box>
                :<></>
            }
            {currentAccount?
                <Box  mb={0} p={4} w='100%' borderWidth="1px" borderRadius="lg">
                    <Heading my={4}  fontSize='xl'>Pick Winner</Heading>
                    <PickWinner 
                        addressContract='0x627b9a657eac8c3463ad17009a424dfe3fdbd0b1'
                        currentAccount={currentAccount}
                    />
                </Box>
                :<></>
            }
        </VStack>
        </>
    )
}

export default Home