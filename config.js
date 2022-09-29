export const INFURA_ID = "1fc7c7c3701c4083b769e561ae251f9a";

export const CONTRACTS = {
    localhost: {
        name: "localhost",
        chainId: 31337,
        contractAddress : "0xC2265816a443691576D9fad0A03472B5c6F1f590",
        contractUsdcaddress : "0x07865c6E87B9F70255377e024ace6630C1Eaa37F",
        contractLendingController : "0xdcAF816E4C8b4885E3c0b9C336EcE6Cd68d0B60D",
        contractTicket : "0x8291b043Bf5DED5DD1753656D1900126488708AC",
      },
    mainnet: {
        name: "Mainnet",
        chainId: 1,
        contractAddress : "0xC2265816a443691576D9fad0A03472B5c6F1f590",
        contractUsdcaddress : "0x07865c6E87B9F70255377e024ace6630C1Eaa37F",
        contractLendingController : "0xdcAF816E4C8b4885E3c0b9C336EcE6Cd68d0B60D",
        contractTicket : "0x8291b043Bf5DED5DD1753656D1900126488708AC",
        blockExplorer: "https://etherscan.io/",
    },
    goerli: {
        name: "Görli",
        chainId: 5,
        contractAddress : "0xC2265816a443691576D9fad0A03472B5c6F1f590",
        contractUsdcaddress : "0x07865c6E87B9F70255377e024ace6630C1Eaa37F",
        contractLendingController : "0xdcAF816E4C8b4885E3c0b9C336EcE6Cd68d0B60D",
        contractTicket : "0x8291b043Bf5DED5DD1753656D1900126488708AC",
        blockExplorer: "https://goerli.etherscan.io/",
    },
    polygon: {
        name: "Polygon",
        chainId: 137,
        contractAddress : "0x74A764aa0e63eC88F86a90fe4eEa886662ba84c8",
        contractUsdcaddress : "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174",
        contractLendingController : "0x7E013B9d8e353CaEEb32dcAE59Ce1F0b95939088",
        contractTicket : "0x9451ef8DB975ada5ba99af50375130384fFa41C9",
        blockExplorer: "https://explorer-mainnet.maticvigil.com//",
    },
    mumbai: {
        name: "Mumbai",
        chainId: 80001,
        contractAddress : "0x9Ffcc79c2Ca66C840B5d9FFf390fB6a42AeDc0E9",
        contractUsdcaddress : "0x0FA8781a83E46826621b3BC094Ea2A0212e71B23",
        contractLendingController : "0xdcAF816E4C8b4885E3c0b9C336EcE6Cd68d0B60D",
        contractTicket : "0x8291b043Bf5DED5DD1753656D1900126488708AC",
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
  