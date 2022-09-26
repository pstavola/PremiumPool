// src/component/Deposit.tsx
import React, { useState } from 'react';
import {Button, NumberInput,  NumberInputField,  FormControl,  FormLabel } from '@chakra-ui/react'
import {ethers} from 'ethers'
import {parseUnits } from 'ethers/lib/utils'
// @ts-ignore
import {PoolABI as abi} from '../abi/PoolABI.tsx'
// @ts-ignore
import {ERC20ABI as erc20abi} from '../abi/ERC20ABI.tsx'
import { Contract } from "ethers"
import { TransactionResponse,TransactionReceipt } from "@ethersproject/abstract-provider"
import { contractAddress, contractUsdcaddress } from '../../config'
//import { message } from 'react-message-popup'

interface Props {
    currentAccount: string | undefined
}

declare let window: any;

export default function Deposit(props:Props){
    const currentAccount = props.currentAccount
    const [amount,setAmount]=useState<string>('100')
    const [approved,setApproved]=useState<boolean>(false)

    async function approve(event:React.FormEvent) {
        event.preventDefault()
        if(!window.ethereum) return
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const signer = provider.getSigner()
        const erc20:Contract = new ethers.Contract(contractUsdcaddress, erc20abi, signer)

        erc20.approve(contractAddress, parseUnits(amount, 6))
        .then((result:boolean) => {
            setApproved(result)
        })
        //.catch((err)=>message.error(err.error.data.message, 10000))
    }

    async function deposit(event:React.FormEvent) {
        event.preventDefault()
        if(!window.ethereum) return
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const signer = provider.getSigner()
        const pool:Contract = new ethers.Contract(contractAddress, abi, signer)

        pool.deposit(parseUnits(amount, 6))
        .then((tr: TransactionResponse) => {
            console.log(`TransactionResponse TX hash: ${tr.hash}`)
            tr.wait().then((receipt:TransactionReceipt)=>{console.log("deposit receipt",receipt)})
        })
        //.catch((err)=>message.error(err.error.data.message, 10000))
    }

    const handleChange = (value:string) => setAmount(value)

    return (
        <form>
        <FormControl my={4}>
        <FormLabel htmlFor='amount'></FormLabel>
        <NumberInput defaultValue={amount} min={0} onChange={handleChange}>
            <NumberInputField />
        </NumberInput>
        <Button my={2} onClick={approve} color='red' isDisabled={!currentAccount}>⬇️ Approve $USDC</Button>
        <Button mx={2} onClick={deposit} color='red' isDisabled={!currentAccount || !approved}>⬇️ Deposit $USDC</Button>
        </FormControl>
        </form>
    )
}