// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract NftWithPresale is ERC721, Ownable {
    using ECDSA for bytes32;

    uint256 public constant MAX_NFT_SUPPLY = 10;
    uint256 public constant MAX_NFT_PER_MINT = 1;
    uint256 public constant PRICE = 0.01 ether;
    uint256 public constant PRESALE_PRICE = 0.005 ether;
    uint256 private _totalSupply;

    uint16 private constant MAX_INT = 0xffff;
    uint16[1] arr = [MAX_INT];

    string private _baseTokenURI;

    address public immutable signerAddress;

    constructor(string memory baseTokenURI_, address signer_)
        ERC721("NftWithPresale", "NWP")
    {
        _baseTokenURI = baseTokenURI_;
        signerAddress = signer_;
    }

    function claimTicketOrBlockTransaction(uint16 ticketNumber) internal {
        require(ticketNumber < MAX_NFT_SUPPLY, "Ticket doesn't exist");
        uint16 storageOffset = 0;
        uint16 offsetWithin16 = ticketNumber % 16;
        uint16 storedBit = (arr[storageOffset] >> offsetWithin16) & uint16(1);
        require(storedBit == 1, "already taken");

        arr[storageOffset] =
            arr[storageOffset] &
            ~(uint16(1) << offsetWithin16);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function mint() public payable {
        require(
            totalSupply() + MAX_NFT_PER_MINT <= MAX_NFT_SUPPLY,
            "Exceeds MAX_NFT_SUPPLY"
        );

        require(PRICE == msg.value, "Ether value sent is not correct");

        _safeMint(_msgSender(), totalSupply());
        _totalSupply += MAX_NFT_PER_MINT;
    }

    function presale(uint16 ticketNumber, bytes calldata signature)
        public
        payable
    {
        require(
            totalSupply() + MAX_NFT_PER_MINT <= MAX_NFT_SUPPLY,
            "Exceeds MAX_NFT_SUPPLY"
        );
        require(
            _validateSignature(signature, _msgSender(), ticketNumber),
            "Invalid signature"
        );
        require(PRESALE_PRICE == msg.value, "Ether value sent is not correct");
        claimTicketOrBlockTransaction(ticketNumber);

        _safeMint(_msgSender(), totalSupply());
        _totalSupply += MAX_NFT_PER_MINT;
    }

    function _validateSignature(
        bytes calldata signature,
        address caller,
        uint256 ticketId
    ) public view returns (bool) {
        bytes32 dataHash = keccak256(abi.encodePacked(caller, ticketId));
        bytes32 message = ECDSA.toEthSignedMessageHash(dataHash);

        address receivedAddress = ECDSA.recover(message, signature);
        return (receivedAddress != address(0) &&
            receivedAddress == signerAddress);
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
}
