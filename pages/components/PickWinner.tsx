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

export default function PickWinner(props:Props){
  const addressContract = props.addressContract
  const currentAccount = props.currentAccount

  async function pick(event:React.FormEvent) {
    event.preventDefault()
    if(!window.ethereum) return    
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner()
    const pool:Contract = new ethers.Contract(addressContract, abi, signer)

    pool.pickWinner()
      .then((tr: TransactionResponse) => {
        console.log(`TransactionResponse TX hash: ${tr.hash}`)
        tr.wait().then((receipt:TransactionReceipt)=>{console.log("pickWinner receipt",receipt)})
      })
      .catch((e:Error)=>console.log(e))
 }

  return (
    <form onSubmit={pick}>
    <FormControl>
      <Button type="submit" isDisabled={!currentAccount}>Pick Winner</Button>
    </FormControl>
    </form>
  )
}