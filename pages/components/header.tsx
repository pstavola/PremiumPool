//pages/components/header.tsx
import React from 'react'
import NextLink from "next/link"
import { Flex, useColorModeValue, Spacer, Heading, LinkBox, LinkOverlay } from '@chakra-ui/react'

const siteTitle="PremiumPool"
export default function Header() {

  return (
    <Flex as='header' bg={useColorModeValue('purple.100', 'purple.900')} p={4} alignItems='center'>
      <Spacer />
      <LinkBox>
        <NextLink href={'/'} passHref>
          <LinkOverlay>
            <Heading size="3xl" color="purple">{siteTitle}</Heading>
          </LinkOverlay>
        </NextLink>
      </LinkBox>
      <Spacer />
    </Flex>
  )
}