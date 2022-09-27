import React, { useEffect,useState } from 'react'
import { Text} from '@chakra-ui/react'
// @ts-ignore
import {ERC20ABI as erc20abi} from '../abi/ERC20ABI.tsx'
import {ethers} from 'ethers'
import { contractUsdcaddress } from '../../config'
//import { message } from 'react-message-popup'

interface Props {
    currentAccount: string | undefined
}

declare let window: any;

export default function USDC(props:Props){
    const currentAccount = props.currentAccount
    const [balance, setBalance] =useState<number|undefined>(undefined)

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
        })//.catch((err)=>message.error(err.error.data.message, 10000))
    } 

    return (
        <Text my={4}><b>$USDC in your account: </b>{balance}</Text>
    )
}
