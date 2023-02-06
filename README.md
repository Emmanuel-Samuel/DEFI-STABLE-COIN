# ERC20 Token
> A simple ERC20 token deployable to the Mainnet.

## Table of Contents
- [Decentralized Stable Coin](#Stable Coin)
  - [Table of Contents](#table-of-contents)
  - [General Information](#general-information)
  - [Technologies Used](#technologies-used)
  - [Features](#features)
  - [Setup](#setup)
  - [Usage](#usage)
  - [Project Status](#project-status)
  - [Room for Improvement](#room-for-improvement)
  - [Contact](#contact)
<!-- * [License](#license) -->


## General Information
- A Decentralized Stable Coin, that can be minted, burn and deposited.


## Technologies Used
- Solidity - version 0.8.17
- Typescript
- Javascript


## Features
- Sender can transfer eth as collateral to receive minted stable coin
- Sender can also burn minted stable coin and recieve eth back
- Deposit and Withdrawal functions implementesd

## Setup
-To run this project, it is required to have installed node.js
-Open the directory
`cd hardhat-erc20`
-Initialise it using
`npm init --yes`
-Install hardhat
`npm install --save-dev hardhat`
-Check if hardhat installed correctly
`npx hardhat`


## Usage
-Compile contract first
`npx hardhat compile`
-Run the test
`npx hardhat test`
-To deploy to mainnet, follow the hints and update the .env file
-Update the hardhat.config.ts with the network config in the .env file
-Deploy using this
`npx hardhat run scripts/deploy.ts --network replace_network_here`
-To deploy to remix
`npx hardhat flatten contracts/StableCoin.sol >> FlattenedStableCoin.sol`



## Project Status
Project is: complete


## Room for Improvement
Room for improvement:
- Add more test functions to the contract



## Contact
Created by [@EmmanuelSamuel](https://www.linktree/mayorkingx) - feel free to contact me!


<!-- ## License -->
<!-- This project is open source and available under the [MIT License](). -->
