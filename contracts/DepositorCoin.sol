// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
//imports our Erc20 token
import { ERC20 } from "./ERC20.sol";

/// @title A Depositor Coin Contract for the Stable Coin
/// @author Emmanuel Mayowa Samuel
/// @notice This contract is built for our stable coin as only the stable coin can access this contract

contract DepositorCoin is ERC20 {

    // state variable declared
    address public owner;

    constructor() ERC20("DepositorCoin", "DPC") {
        // sender has to be owner
        owner = msg.sender;
    }

    // A function to mint accessible only by owner
    function mint(address to, uint256 amount) external {

        // checks if the sender is the owner(Stable Coin)
        require(msg.sender == owner, "DPC: Only owner can mint");

        // calls the mint function
        _mint(to, amount);
    }

    // A function to burn only accessible only by owner
    function burn(address from, uint256 amount) external {

        // checks if the sender is the owner(Stable Coin)
        require(msg.sender == owner, "DPC: Only owner can burn");

        // calls the burn function
        _burn(from, amount);
    }
}