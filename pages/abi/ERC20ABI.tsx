export const ERC20ABI = [
    "function balanceOf(address owner) view returns (uint256)",
    "function totalSupply() view returns (uint256)",
    "function decimals() view returns (uint8)",
    "function symbol() view returns (string)",
    "function mint(address _minter, uint256 _amount) public onlyOwner",
    "function burn(address _account, uint256 _amount) public onlyOwner",
    "function transfer(address to, uint amount) returns (bool)",

    "event Transfer(address indexed from, address indexed to, uint amount)"
];