// pages/_app.tsx
import React, { ReactNode } from 'react'
import { ChakraProvider } from '@chakra-ui/react'
import type { AppProps } from 'next/app'
// @ts-ignore
import { Layout } from './components/layout.tsx'

function MyApp({ Component, pageProps }: AppProps) {
  return (
      <ChakraProvider>
        <Layout>
        <Component {...pageProps} />
        </Layout>
      </ChakraProvider>
  )
}

export default MyApp