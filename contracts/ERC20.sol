//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

//define your contract name
contract ERC20 {
    //define your state variables 
    uint256 public totalSupply;
    string public name;
    string public symbol;
    //events for both transfer and approval
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    //mapping for storing the balances for the address
    mapping(address => uint256) public balanceOf;
    //mapping for allowance for someone else to send the tokens
    mapping(address => mapping(address => uint256)) public allowance;

    //set values for the variables using a constructor
    constructor(string memory name_, string memory symbol_){
        name = name_;
        symbol = symbol_;
    
    }

    //hardcode the decimal as a view function, cheaper from a gas perpective
    function decimals() external pure returns (uint8) {
        return 18;
    }

    //tranfer function takes in the recipient, amount and returns bool
    function transfer(address recipient, uint256 amount) external returns (bool) {
        return __transfer(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        //making sure the caller is allowed to make the transfer
        uint256 currentAllowance = allowance[sender][msg.sender];
        //incase it exceeds it should revert
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        //updates the allowance mapping
        allowance[sender][msg.sender] = currentAllowance - amount;

        emit Approval(sender, msg.sender, allowance[sender][msg.sender]);

        return __transfer(sender, recipient, amount);
    }

    //this function allows the some other address to spend the token on their behalf
    //takes in spender address and approved amount
    function approve(address spender, uint256 amount) external returns(bool) {
        //dont approve to zero address
        require(spender != address(0), "ERC20: approve to the zero address");
        //sets allowance to the spender
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function __transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        //checks so the sender doesn't send to an invalid address
        require(recipient != address(0), "ERC20: transfer to the zero address");
        //checks the sender balance 
        uint256 senderBalance = balanceOf[sender];
        //checks if the sender has enough tokens for the transfer
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        //removes amount from the sender
        balanceOf[sender] = senderBalance - amount;
        //adds it to the recipient
        balanceOf[recipient] += amount;

        emit Transfer(sender, recipient, amount);
        //returns true if successful
        return true;
    }

    //function that mints tokens to an address, takes in address and amount
    function _mint(address to, uint256 amount) internal {
        //checks address is not 0
        require(to != address(0), "ERC20: mint to the zero address");
        //increase total suppply
        totalSupply += amount;
        //updates the balance
        balanceOf[to] += amount;

        emit Transfer(address(0), to, amount);
    }

        //function that burn tokens to an address, takes in address and amount
    function _burn(address from, uint256 amount) internal {
        //checks address is not 0
        require(from != address(0), "ERC20: burn from the zero address");
        //increase total suppply
        totalSupply -= amount;
        //updates the balance
        balanceOf[from] -= amount;

        emit Transfer(from, address(0), amount);
    }
}