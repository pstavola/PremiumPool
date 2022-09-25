// src/component/Deposit.tsx
import React, { useState } from 'react';
import {Button, NumberInput,  NumberInputField,  FormControl,  FormLabel } from '@chakra-ui/react'
import {ethers} from 'ethers'
import {parseEther } from 'ethers/lib/utils'
// @ts-ignore
import {PoolABI as abi} from '../abi/PoolABI.tsx'
import { Contract } from "ethers"
import { TransactionResponse,TransactionReceipt } from "@ethersproject/abstract-provider"
import { contractAddress } from '../../config'
import { message } from 'react-message-popup'

interface Props {
    currentAccount: string | undefined
}

declare let window: any;

export default function Deposit(props:Props){
    const currentAccount = props.currentAccount
    const [amount,setAmount]=useState<string>('100')

    async function deposit(event:React.FormEvent) {
        const error = "";
        event.preventDefault()
        if(!window.ethereum) return
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const signer = provider.getSigner()
        const pool:Contract = new ethers.Contract(contractAddress, abi, signer)

        pool.deposit(parseEther(amount))
        .then((tr: TransactionResponse) => {
            console.log(`TransactionResponse TX hash: ${tr.hash}`)
            tr.wait().then((receipt:TransactionReceipt)=>{console.log("deposit receipt",receipt)})
        })
        .catch((err)=>message.error(err.error.data.message, 10000))
    }

    const handleChange = (value:string) => setAmount(value)

    return (
        <form onSubmit={deposit}>
        <FormControl my={4}>
        <FormLabel htmlFor='amount'></FormLabel>
        <NumberInput defaultValue={amount} min={0} onChange={handleChange}>
            <NumberInputField />
        </NumberInput>
        <Button type="submit" color='red' isDisabled={!currentAccount}>⬇️ Deposit $USDC</Button>
        </FormControl>
        </form>
    )
}