import React, { useEffect,useState } from 'react'
import { Text} from '@chakra-ui/react'
// @ts-ignore
import {PoolABI as abi} from '../abi/PoolABI.tsx'
// @ts-ignore
import {DrawControllerABI as drawABI} from '../abi/DrawControllerABI.tsx'
import {ethers} from 'ethers'

interface Props {
    addressContract: string,
    currentAccount: string | undefined
}

declare let window: any;

export default function Timeleft(props:Props){
  const addressContract = props.addressContract
  const [addressDrawController, SetAddressDrawController] =useState<string>("")
  const [timeleft, SetTimeleft] =useState<string>("")

  useEffect( () => {
    if(!window.ethereum) return

    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const pool = new ethers.Contract(addressContract, abi, provider);
    pool.getDrawAddress().then((result:string)=>{
        SetAddressDrawController(result)
    }).catch('error', console.error)

    console.log(addressDrawController)
    
    const draw = new ethers.Contract(addressDrawController, drawABI, provider)
    draw.getCurrentDrawEndtime().then((result:string)=>{
        SetTimeleft(result)
    }).catch('error', console.error)
    console.log(timeleft)
  },[])

  return (
    <div>
        <Text my={4}><b>Time left to next draw</b>: {timeleft}</Text>
    </div>
  )
}
