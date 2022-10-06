// src/component/Deposit.tsx
import React, { useState, useRef } from 'react';
import {Button, NumberInput,  NumberInputField,  FormControl,  FormLabel } from '@chakra-ui/react'
import {ethers} from 'ethers'
import {parseUnits } from 'ethers/lib/utils'
// @ts-ignore
import {PoolABI as abi} from '../abi/PoolABI.tsx'
import { Contract } from "ethers"
import { TransactionResponse,TransactionReceipt } from "@ethersproject/abstract-provider"

import { ToastContainer, toast, Slide } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

interface Props {
    currentAccount: string | undefined
    contractAddress: string | undefined
}

declare let window: any;

export default function Withdraw(props:Props){
  const currentAccount = props.currentAccount
  const contractAddress = props.contractAddress
  const [amount,setAmount]=useState<string>('100')
  const toastId = useRef(null);

  const pending = () => {
    toastId.current = toast.info("Transaction Pending...", {
        position: "top-right",
        autoClose: false,
        hideProgressBar: false,
        closeOnClick: false,
        pauseOnHover: true,
        draggable: true,
        progress: undefined,
    });
  };

  const success = () => {
      toast.dismiss(toastId.current);
      toast.success("Transaction Complete!", {
          position: "top-right",
          autoClose: 5000,
          hideProgressBar: false,
          closeOnClick: false,
          pauseOnHover: true,
          draggable: true,
          progress: undefined,
      });
  };

  const error = (msg) => {
      toast.error(msg, {
        position: "top-right",
        autoClose: 5000,
        hideProgressBar: false,
        closeOnClick: false,
        pauseOnHover: true,
        draggable: true,
        progress: undefined,
      });
  };

  async function withdraw(event:React.FormEvent) {
    event.preventDefault()
    if(!window.ethereum) return    
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner()
    const pool:Contract = new ethers.Contract(contractAddress, abi, signer)

    pool.withdraw(parseUnits(amount, 6))
      .then((tr: TransactionResponse) => {
        console.log(`TransactionResponse TX hash: ${tr.hash}`);
        pending();
        tr.wait().then((receipt:TransactionReceipt) => {
            console.log("withdraw receipt",receipt);
            success();
        });
      }).catch((err)=>error({ err }.err.reason))
 }

  const handleChange = (value:string) => setAmount(value)

  return (
    <form onSubmit={withdraw}>
    <FormControl my={4}>
    <FormLabel htmlFor='amount'></FormLabel>
      <NumberInput defaultValue={amount} min={0} onChange={handleChange}>
        <NumberInputField />
      </NumberInput>
      <Button type="submit" color='red' isDisabled={!currentAccount}>⬆️ Withdraw $USDC</Button>
    </FormControl>
    </form>
  )
}