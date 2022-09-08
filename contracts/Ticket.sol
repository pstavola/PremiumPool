// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title PremiumPool Ticket
 * @author patricius
 * @notice Each NFT of this collection represent a ticket for PremiumPool draw
 * @dev A standard ERC721 implementation. Artwork stored on IPFS
 */
contract PremiumPoolTicket is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Ownable
{
    using Counters for Counters.Counter;

    /* ========== GLOBAL VARIABLES ========== */

    Counters.Counter public tokenIdCounter; //token id counter incremented per each mint

    /* ========== CONSTRUCTOR ========== */

    constructor() ERC721("PremiumPool Ticket", "PPT") {}
    
    /* ========== FUNCTIONS ========== */

    /**
     * @notice mints token using function overload.
     */
    function mintItem() public payable {
        mintItem(1);
    }

    /**
     * @notice mints the amount of token requested by iterating parent _safeMint function. Only the Owner contract can mint. ID counter is increased each minted token.
     * @param _amount amount of tokens to be minted
     */
    function mintItem(uint256 _amount)
        public
        payable
        onlyOwner
    {
        for(uint256 i=0; i < _amount; i++){
            tokenIdCounter.increment();
            _safeMint(msg.sender, tokenIdCounter.current());
        }
    }

    /**
     * @notice override required by Solidity.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @notice override required by Solidity.
     */
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    /**
     * @notice override required by Solidity.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    /**
     * @notice override required by Solidity.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
