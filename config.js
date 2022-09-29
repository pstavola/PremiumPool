export const INFURA_ID = "1fc7c7c3701c4083b769e561ae251f9a";

export const CONTRACTS = {
    localhost: {
        name: "localhost",
        chainId: 31337,
        currency: "ETH",
        contractAddress : "0xC2265816a443691576D9fad0A03472B5c6F1f590",
        contractUsdcaddress : "0x07865c6E87B9F70255377e024ace6630C1Eaa37F",
        contractLendingController : "0xdcAF816E4C8b4885E3c0b9C336EcE6Cd68d0B60D",
        contractTicket : "0x8291b043Bf5DED5DD1753656D1900126488708AC",
      },
    mainnet: {
        name: "Mainnet",
        chainId: 1,
        currency: "ETH",
        contractAddress : "0xC2265816a443691576D9fad0A03472B5c6F1f590",
        contractUsdcaddress : "0x07865c6E87B9F70255377e024ace6630C1Eaa37F",
        contractLendingController : "0xdcAF816E4C8b4885E3c0b9C336EcE6Cd68d0B60D",
        contractTicket : "0x8291b043Bf5DED5DD1753656D1900126488708AC",
        blockExplorer: "https://etherscan.io/",
    },
    goerli: {
        name: "Görli",
        chainId: 5,
        currency: "ETH",
        contractAddress : "0xBacB905C1cA6d033EcdE8B6FE068412090Ff64b1",
        contractUsdcaddress : "0x9FD21bE27A2B059a288229361E2fA632D8D2d074",
        contractLendingController : "0x2699cdb77DBda9A78c3C0528bB80d9C1949d624D",
        contractTicket : "0x4Dd2B987Add365aF52097B81Df9Dbd528DB3b992",
        blockExplorer: "https://goerli.etherscan.io/",
    },
    polygon: {
        name: "Polygon",
        chainId: 137,
        currency: "MATIC",
        contractAddress : "0x18e7F6638c2E0AC3D8600a5DDfDE7D466Fa02784",
        contractUsdcaddress : "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174",
        contractLendingController : "0x97e0d17224d363d58ac62306593efee708148ed5",
        contractTicket : "0x3e17ae649f13e11630efc207cdf40e5575b8a4df",
        blockExplorer: "https://explorer-mainnet.maticvigil.com/",
    },
    mumbai: {
        name: "Mumbai",
        chainId: 80001,
        currency: "MATIC",
        contractAddress : "0x9Ffcc79c2Ca66C840B5d9FFf390fB6a42AeDc0E9",
        contractUsdcaddress : "0x0FA8781a83E46826621b3BC094Ea2A0212e71B23",
        contractLendingController : "0x9fa61630824e3420414589e606d7eaa55e5f69f6",
        contractTicket : "0x186140ec15632b948924bbe43fecedaffb0ddddc",
        blockExplorer: "https://mumbai-explorer.matic.today/",
    },
  };
  
  export const CONTRACT = chainId => {
    for (const n in CONTRACTS) {
      if (CONTRACTS[n].chainId === chainId) {
        return CONTRACTS[n];
      }
    }
  };
  