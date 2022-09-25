// pages/components/layout.tsx
import React, { ReactNode } from 'react'
import { Text, Center, Container, useColorModeValue } from '@chakra-ui/react'
// @ts-ignore
import Header from './header.tsx'

type Props = {
  children: ReactNode
}

export function Layout(props: Props) {
  return (
    <div>
      <Header />
      <Container maxW="container.md" py='8'>
        {props.children}
      </Container>
      <Center as="footer" bg={useColorModeValue('purple.100', 'purple.700')} p={6}>
          <Text fontSize="md" color='purple'>patricius/2022</Text>
      </Center>
    </div>
  )
}