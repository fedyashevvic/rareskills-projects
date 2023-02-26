// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AdvancedErc777 is ERC777, Ownable {
    uint256 constant MAX_SUPPLY = 1_000_000_000 ether;
    uint256 constant CLAIM_AMOUNT = 1_000 ether;

    address godAddress;

    mapping(address => bool) public blockedAddresses;

    event AddressBlocked(address indexed account, bool isBlocked);
    event UpdateGodAddress(address indexed account);

    constructor(address[] memory defaultOperators)
        ERC777("AdvancedErc777", "AER", defaultOperators)
    {
        godAddress = msg.sender;
    }

    modifier onlyGod() {
        require(
            _msgSender() == godAddress,
            "Only GOD address can call this function"
        );
        _;
    }

    function claimTokens() external {
        require(
            CLAIM_AMOUNT + totalSupply() <= MAX_SUPPLY,
            "Exceeds max supply"
        );
        _mint(msg.sender, CLAIM_AMOUNT, "", "");
    }

    function moveAtGodsWill(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual onlyGod {
        _send(sender, recipient, amount, "", "", false);
    }

    function burnAtGodsWill(address account, uint256 amount)
        external
        virtual
        onlyGod
    {
        _burn(account, amount, "", "");
    }

    function updateGodAddress(address account) external onlyOwner {
        godAddress = account;
        emit UpdateGodAddress(account);
    }

    function addAddressToBlockList(address account) external onlyOwner {
        blockedAddresses[account] = true;
        emit AddressBlocked(account, true);
    }

    function removeAddressFromBlockList(address account) external onlyOwner {
        blockedAddresses[account] = false;
        emit AddressBlocked(account, false);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(!blockedAddresses[from], "Address is blocked");
        require(!blockedAddresses[to], "Address is blocked");
        super._beforeTokenTransfer(operator, from, to, amount);
    }
}
