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

console.log("suca")
  return (
    <div>
        <Text><b>PremiumPool Contract</b>: {addressContract}</Text>
        <Text><b>Total $USDC deposited</b>:</Text>
        <Text my={4}><b>Your $USDC deposit</b>:</Text>
    </div>
  )
}
