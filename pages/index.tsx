// pages/index.tsx
import React, { ReactNode } from 'react'
import type { NextPage } from 'next'
import Head from 'next/head'
import NextLink from "next/link"
import { VStack, Heading, Box, LinkOverlay, LinkBox} from "@chakra-ui/layout"
import { Text, Button } from '@chakra-ui/react'
import { useState, useEffect} from 'react'
import {ethers} from "ethers"
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

declare let window:any

const Home: NextPage = () => {
    const [balance, setBalance] = useState<string | undefined>()
    const [currentAccount, setCurrentAccount] = useState<string | undefined>()
    const [chainId, setChainId] = useState<number | undefined>()
    const [chainname, setChainName] = useState<string | undefined>()

    useEffect(() => {
        if(!currentAccount || !ethers.utils.isAddress(currentAccount)) return
        //client side code
        if(!window.ethereum) return
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        provider.getBalance(currentAccount).then((result)=>{
        setBalance(ethers.utils.formatEther(result))
        })
        provider.getNetwork().then((result)=>{
        setChainId(result.chainId)
        setChainName(result.name)
        })
    },[currentAccount])

    const onClickConnect = () => {
        //client side code
        if(!window.ethereum) {
        console.log("please install MetaMask")
        return
        }

        //we can do it using ethers.js
        const provider = new ethers.providers.Web3Provider(window.ethereum)

        // MetaMask requires requesting permission to connect users accounts
        provider.send("eth_requestAccounts", [])
        .then((accounts)=>{
        if(accounts.length>0) setCurrentAccount(accounts[0])
        })
        .catch((e)=>console.log(e))
    }

    const onClickDisconnect = () => {
        console.log("onClickDisConnect")
        setBalance(undefined)
        setCurrentAccount(undefined)
    }

    return (
        <>
        <Head>
            <title>PremiumPool</title>
        </Head>

        <Heading as="h3"  my={4}>Deposit now to have a chance to win!</Heading>          
        <VStack>
            <Box w='100%' my={4}>
            {currentAccount? 
                <Button type="button" w='100%' onClick={onClickDisconnect}>
                        Disconnect
                </Button>
                : <Button type="button" w='100%' onClick={onClickConnect}>
                        Connect MetaMask
                </Button>
            }
            </Box>
            {currentAccount?
                <LinkBox  my={4} p={4} w='100%' borderWidth="1px" borderRadius="lg">
                    <NextLink href="https://github.com/NoahZinsmeister/web3-react/tree/v6" passHref>
                    <LinkOverlay>
                        <Heading my={4}  fontSize='xl'>Account {currentAccount}</Heading>
                        <Text>ETH Balance: {balance}</Text>
                        <USDC addressUsdcContract='0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48' currentAccount='0x20Df8B290c61094c1AE47827d03eB55e769eED9a'/>
                        <Text>Chain name: {chainname}</Text>
                        <Text>Chain Id: {chainId}</Text>
                    </LinkOverlay>
                    </NextLink>
                </LinkBox>
                :<></>
            }

            <Box  mb={0} p={4} w='100%' borderWidth="1px" borderRadius="lg">
                <Heading my={4}  fontSize='xl'>PremiumPool Info</Heading>
                <ReadContract
                    addressContract='0x627b9a657eac8c3463ad17009a424dfe3fdbd0b1'
                    currentAccount='0x20Df8B290c61094c1AE47827d03eB55e769eED9a'
                />
            </Box>

            <Box  mb={0} p={4} w='100%' borderWidth="1px" borderRadius="lg">
                <Heading my={4}  fontSize='xl'>Deposit $USDC</Heading>
                <Deposit 
                    addressContract='0x627b9a657eac8c3463ad17009a424dfe3fdbd0b1'
                    currentAccount='0x20Df8B290c61094c1AE47827d03eB55e769eED9a'
                />
            </Box>

            <Box  mb={0} p={4} w='100%' borderWidth="1px" borderRadius="lg">
                <Heading my={4}  fontSize='xl'>Withdraw $USDC</Heading>
                <Withdraw 
                    addressContract='0x627b9a657eac8c3463ad17009a424dfe3fdbd0b1'
                    currentAccount='0x20Df8B290c61094c1AE47827d03eB55e769eED9a'
                />
            </Box>

            <Box  mb={0} p={4} w='100%' borderWidth="1px" borderRadius="lg">
                <Heading my={4}  fontSize='xl'>Pick Winner</Heading>
                <PickWinner 
                    addressContract='0x627b9a657eac8c3463ad17009a424dfe3fdbd0b1'
                    currentAccount='0x20Df8B290c61094c1AE47827d03eB55e769eED9a'
                />
            </Box>
        </VStack>
        </>
    )
}

export default Home