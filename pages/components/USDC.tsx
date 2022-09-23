import React, { useEffect,useState } from 'react'
import { Text} from '@chakra-ui/react'
// @ts-ignore
import {ERC20ABI as erc20abi} from '../abi/ERC20ABI.tsx'
import {ethers} from 'ethers'

interface Props {
    addressUsdcContract: string,
    currentAccount: string | undefined
}

declare let window: any;

export default function USDC(props:Props){
  const addressUsdcContract = props.addressUsdcContract
  const currentAccount = props.currentAccount
  const [balance, SetBalance] =useState<number|undefined>(undefined)

  useEffect(()=>{
    if(!window.ethereum) return
    if(!currentAccount) return

    queryTokenBalance(window)
  },[currentAccount])

  async function queryTokenBalance(window:any){
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const erc20 = new ethers.Contract(addressUsdcContract, erc20abi, provider);

    erc20.balanceOf(currentAccount)
    .then((result:string)=>{
        SetBalance(Number(ethers.utils.formatEther(result)))
    })
    .catch('error', console.error)
  }  

  return (
    <Text>$USDC Balance: {balance}</Text>
  )
}
