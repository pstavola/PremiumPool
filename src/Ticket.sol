// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PremiumPoolTicket
 * @author Patrizio Stavola
 * @notice PremiumPool $PPT token used as tickets to reflect partecipation to the deposit pool and be eligible for the draw
*/
contract PremiumPoolTicket is ERC20, Ownable {

    constructor() ERC20("PremiumPoolTicket", "PPT") {}

    /**
     * @notice wrapper for the _mint function. Only PremiumPool contract cant mint tokens
     * @param _minter address of the user to mint
     * @param _amount amount of tokens to mint
    */
    function mint(address _minter, uint256 _amount) public onlyOwner {
        super._mint(_minter , _amount);
    }

    /**
     * @notice wrapper for the _burn function. Only PremiumPool contract cant burn tokens
     * @param _account address of the user burning
     * @param _amount amount of tokens to burn
    */
    function burn(address _account, uint256 _amount) public onlyOwner {
        super._burn(_account , _amount);
    }

    /**
     * @notice using 6 decimals representation to align to $USDC token
    */
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}