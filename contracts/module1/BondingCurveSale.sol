// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/BancorFormula.sol";

contract BondingCurveSale is ERC20, BancorFormula, Ownable {
    /**
     * @dev Available balance of reserve token in contract
     */
    uint256 public poolBalance;

    /*
     * @dev reserve ratio, represented in ppm, 1-1000000
     * @dev In out case it is 1/2
     */
    uint32 public reserveRatio;

    event Mint(uint256 amountMinted, uint256 totalCost);
    event Withdraw(uint256 amountWithdrawn, uint256 reward);

    constructor() ERC20("BondingCurveSale", "BCS") {
        reserveRatio = 500_000; // 1/2

        _mint(msg.sender, 1 ether);
        poolBalance = 0.0001 ether;
    }

    /**
     * @dev Buy tokens
     */
    function buy() public payable {
        require(msg.value > 0);
        uint256 tokensToMint = calculatePurchaseReturn(
            totalSupply(),
            poolBalance,
            reserveRatio,
            msg.value
        );
        _mint(_msgSender(), tokensToMint);
        poolBalance = poolBalance + msg.value;
        emit Mint(tokensToMint, msg.value);
    }

    /**
     * @dev Sell tokens
     */
    function sell(uint256 sellAmount) public returns (bool) {
        require(sellAmount > 0 && balanceOf(_msgSender()) >= sellAmount);
        uint256 ethAmount = calculateSaleReturn(
            totalSupply(),
            poolBalance,
            reserveRatio,
            sellAmount
        );
        poolBalance = poolBalance - ethAmount;
        _burn(_msgSender(), sellAmount);
        payable(_msgSender()).transfer(ethAmount);
        emit Withdraw(sellAmount, ethAmount);
        return true;
    }
}
