//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title An Oracle that provides offchain data to blockchain
/// @author EMMANUEL MAYOWA SAMUEL
/// @notice Implements a local oracle

contract Oracle {

    // state variables
    address public owner;
    uint256 private price;

    constructor() {

    // owner has to be the sender
        owner = msg.sender;
    }

    // this function reads the price and returns it
    function getPrice() external view returns (uint256) {
        return price;
    }

    // this function sets price and returns the new price
    function setPrice(uint256 newPrice) external {

        // checks so only sender can set price
        require(msg.sender == owner, "Oracle: only owner");
        price = newPrice;
    }
}