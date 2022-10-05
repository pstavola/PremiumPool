import React, { useEffect,useState } from 'react'
import { Text, FormControl, Button } from '@chakra-ui/react'
// @ts-ignore
import {PoolABI as abi} from '../abi/PoolABI.tsx'
// @ts-ignore
import {ERC20ABI as erc20abi} from '../abi/ERC20ABI.tsx'
import { ethers, Contract} from 'ethers'
import { TransactionResponse,TransactionReceipt } from '@ethersproject/abstract-provider'
import humanizeDuration from 'humanize-duration'

import { useRef } from "react";
import { ToastContainer, toast, Slide } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

interface Props {
    currentAccount: string | undefined
    contractAddress: string | undefined
    contractTicket: string | undefined
}

declare let window: any;

export default function ReadContract(props:Props){
    const currentAccount = props.currentAccount
    const contractAddress = props.contractAddress
    const contractTicket = props.contractTicket
    const [totalDeposit, setTotalDeposit]= useState<string>("")
    const [timeleft, SetTimeleft] =useState<string>("")
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

    async function pick(event:React.FormEvent) {
        event.preventDefault()
        if(!window.ethereum) return 
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const signer = provider.getSigner()
        const pool:Contract = new ethers.Contract(contractAddress, abi, signer)

        pool.pickWinner()
        .then((tr: TransactionResponse) => {
            console.log(`TransactionResponse TX hash: ${tr.hash}`);
            pending();
            tr.wait().then((receipt:TransactionReceipt) => {
                console.log("pickWinner receipt",receipt);
                success();
            });
        }).catch((err)=>error({ err }.err.reason))
    }

    useEffect( () => {
        if(!window.ethereum) return

        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const pool = new ethers.Contract(contractAddress, abi, provider);

        queryDeposit(window)

        pool.getTimeLeft().then((result:string)=>{
            SetTimeleft(result)
        }).catch((err)=>error({ err }.err.reason))

        // listen for changes on an Ethereum address
        console.log(`listening for Transfer...`)

        const deposit = pool.filters.Deposit(null, null)
        provider.on(deposit, (from, to, amount, event) => {
            console.log('Transfer|sent', { from, to, amount, event })
            queryDeposit(window)
        })

        const withdraw = pool.filters.Withdraw(null, null)
            provider.on(withdraw, (from, to, amount, event) => {
                console.log('My Withdraw', { from, to, amount, event })
                queryDeposit(window)
            })

        // remove listener when the component is unmounted
        return () => {
            provider.removeAllListeners(deposit)
            provider.removeAllListeners(withdraw)
        }   
    },[])

    async function queryDeposit(window:any){
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const ticket = new ethers.Contract(contractTicket, erc20abi, provider)

        ticket.totalSupply().then((result:string)=>{
            setTotalDeposit(ethers.utils.formatUnits(result, 6))
        }).catch((err)=>error({ err }.err.reason))
    }

    return (
        <div>
            <Text my={4}><b>PremiumPool Contract</b>: {contractAddress}</Text>
            <Text my={4}><b>Total $USDC deposited</b>: {totalDeposit}</Text>
            <Text my={4}><b>Time left to next draw</b>: {timeleft && humanizeDuration(Number(timeleft) * 1000)}</Text>
            <form onSubmit={pick}>
                <FormControl>
                    <Button type="submit" color='red' isDisabled={!currentAccount}> 🚀 🎖 👩‍🚀 Pick Winner! 🎉 🍾 🔥</Button>
                </FormControl>
            </form>
        </div>
        
    )
}
