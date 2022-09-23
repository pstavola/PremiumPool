import React, { useEffect,useState } from 'react'
import { Text} from '@chakra-ui/react'
// @ts-ignore
import {PoolABI as abi} from '../abi/PoolABI.tsx'
import {ethers} from 'ethers'

interface Props {
    addressContract: string,
    currentAccount: string | undefined
}

declare let window: any;

export default function ReadContract(props:Props){
  const addressContract = props.addressContract
  const currentAccount = props.currentAccount
  const [userDeposit, setUserDeposited]=useState<string>()
  const [totalDeposit, setTotalDeposit]= useState<string>("")

  useEffect( () => {
    if(!window.ethereum) return

    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const pool = new ethers.Contract(addressContract, abi, provider);
    pool.getUserDeposti(currentAccount).then((result:string)=>{
        setUserDeposited(ethers.utils.formatEther(result))
    }).catch('error', console.error)

    pool.getTotalDeposit().then((result:string)=>{
        setTotalDeposit(ethers.utils.formatEther(result))
    }).catch('error', console.error);
  },[])

  return (
    <div>
        <Text my={4}><b>PremiumPool Contract</b>: {addressContract}</Text>
        <Text my={4}><b>Total $USDC deposited</b>: {totalDeposit}</Text>
        <Text><b>Your $USDC deposit</b>: {userDeposit}</Text>
    </div>
  )
}
