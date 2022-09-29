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
        contractAddress : "0xc8f0D1bddDBc40f111288376A6E86cfEa257bDE6",
        contractUsdcaddress : "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174",
        contractLendingController : "0x7d86009de0e89489d9713a401549483b96f8eea0 ",
        contractTicket : "0xff6a4dd96ec3061e1bf002ef5daf78eaf31c723d",
        blockExplorer: "https://explorer-mainnet.maticvigil.com/",
    },
    mumbai: {
        name: "Mumbai",
        chainId: 80001,
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
  