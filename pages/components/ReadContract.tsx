import React, { useEffect,useState } from 'react'
import { Text} from '@chakra-ui/react'
// @ts-ignore
import {PoolABI as abi} from '../abi/PoolABI.tsx'
// @ts-ignore
import {ERC20ABI as erc20abi} from '../abi/ERC20ABI.tsx'
import {ethers} from 'ethers'

interface Props {
    addressPoolContract: string,
    addressUsdcContract: string,
    currentAccount: string | undefined
}

declare let window: any;

export default function ReadContract(props:Props){
  const addressPoolContract = props.addressPoolContract
  const addressUsdcContract = props.addressUsdcContract
  const currentAccount = props.currentAccount
  const [userDeposit, setUserDeposited]=useState<string>()
  const [totalDeposit, setTotalDeposit]= useState<string>("")
  const [balance, SetBalance] =useState<number|undefined>(undefined)

  useEffect( () => {
    if(!window.ethereum) return

    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const pool = new ethers.Contract(addressPoolContract, abi, provider);
    pool.getUserDeposti(currentAccount).then((result:string)=>{
        setUserDeposited(ethers.utils.formatEther(result))
    }).catch('error', console.error)

    pool.getTotalDeposit().then((result:string)=>{
        setTotalDeposit(ethers.utils.formatEther(result))
    }).catch('error', console.error);
  },[])

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
    <div>
        <Text my={4}><b>PremiumPool Contract</b>: {addressPoolContract}</Text>
        <Text my={4}><b>Total $USDC deposited</b>: {totalDeposit}</Text>
        <Text><b>Your $USDC deposit</b>: {userDeposit}</Text>
        <Text><b>Your $USDC balance</b>: {balance}</Text>
    </div>
  )
}
