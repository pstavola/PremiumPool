import React, { useEffect,useState, useRef } from 'react'
import { Text} from '@chakra-ui/react'
// @ts-ignore
import {ERC20ABI as erc20abi} from '../abi/ERC20ABI.tsx'
import {ethers} from 'ethers'

import { ToastContainer, toast, Slide } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

interface Props {
    currentAccount: string | undefined
    contractUsdcaddress: string | undefined
}

declare let window: any;

export default function USDC(props:Props){
    const currentAccount = props.currentAccount
    const contractUsdcaddress = props.contractUsdcaddress
    const [balance, setBalance] =useState<number|undefined>(undefined)

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

    useEffect(()=>{
        if(!window.ethereum) return
        if(!currentAccount || !ethers.utils.isAddress(currentAccount)) return

        queryTokenBalance(window)

        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const erc20 = new ethers.Contract(contractUsdcaddress, erc20abi, provider)

        // listen for changes on an Ethereum address
        console.log(`listening for Transfer...`)

        const fromMe = erc20.filters.Transfer(currentAccount, null)
        provider.on(fromMe, (from, to, amount, event) => {
            console.log('Transfer|sent', { from, to, amount, event })
            queryTokenBalance(window)
        })

        const toMe = erc20.filters.Transfer(null, currentAccount)
        provider.on(toMe, (from, to, amount, event) => {
            console.log('Transfer|received', { from, to, amount, event })
            queryTokenBalance(window)
        })

        // remove listener when the component is unmounted
        return () => {
            provider.removeAllListeners(toMe)
            provider.removeAllListeners(fromMe)
        }    
    }, [currentAccount])

    async function queryTokenBalance(window:any){
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const erc20 = new ethers.Contract(contractUsdcaddress, erc20abi, provider);

        erc20.balanceOf(currentAccount).then((result:number)=>{
            setBalance(Number(ethers.utils.formatUnits(result, 6)))
        }).catch((err)=>error({ err }.err.reason))
    } 

    return (
        <Text my={4}><b>$USDC in your account: </b>{balance}</Text>
    )
}
