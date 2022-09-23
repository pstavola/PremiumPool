// src/component/Deposit.tsx
import React, { useEffect,useState } from 'react';
import {Button, Input , NumberInput,  NumberInputField,  FormControl,  FormLabel } from '@chakra-ui/react'
import {ethers} from 'ethers'
import {parseEther } from 'ethers/lib/utils'
// @ts-ignore
import {PoolABI as abi} from '../abi/PoolABI.tsx'
import { Contract } from "ethers"
import { TransactionResponse,TransactionReceipt } from "@ethersproject/abstract-provider"

interface Props {
    addressContract: string,
    currentAccount: string | undefined
}

declare let window: any;

export default function Withdraw(props:Props){
  const addressContract = props.addressContract
  const currentAccount = props.currentAccount
  const [amount,setAmount]=useState<string>('100')

  async function withdraw(event:React.FormEvent) {
    event.preventDefault()
    if(!window.ethereum) return    
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner()
    const pool:Contract = new ethers.Contract(addressContract, abi, signer)

    pool.withdraw(parseEther(amount))
      .then((tr: TransactionResponse) => {
        console.log(`TransactionResponse TX hash: ${tr.hash}`)
        tr.wait().then((receipt:TransactionReceipt)=>{console.log("withdraw receipt",receipt)})
      })
      .catch((e:Error)=>console.log(e))
 }

  const handleChange = (value:string) => setAmount(value)

  return (
    <form onSubmit={withdraw}>
    <FormControl>
    <FormLabel htmlFor='amount'>Amount: </FormLabel>
      <NumberInput defaultValue={amount} min={0} onChange={handleChange}>
        <NumberInputField />
      </NumberInput>
      <Button type="submit" isDisabled={!currentAccount}>Withdraw</Button>
    </FormControl>
    </form>
  )
}