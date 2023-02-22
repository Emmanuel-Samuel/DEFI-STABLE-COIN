/// DATE CREATED: 06/02/2023                                 
/// REVISED DATE: 06/02/2023                                                                          

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
// Imports our Erc20 token
import { ERC20 } from "./ERC20.sol";
import { DepositorCoin } from "./DepositorCoin.sol";
import { Oracle } from "./Oracle.sol";
import { WadLib } from "./WadLib.sol";

/// @title DECENTRALIZED STABLE COIN
/// @author EMMANUEL MAYOWA SAMUEL
/// @notice This Stable coin can be transfered, deposited, minted and burn
/// @dev This Contract was built on a previous ERC20 Token Contract created. 

/// Stablecoin contract inherits from the ERC20 contract
contract StableCoin is ERC20 {
    /// @notice All our State Variables are being declared here
    /// @return StateVariables
    
    /// imports the wadlib library and allows the uint256 data type
    using WadLib for uint256;
    /// defines a custom error that can be used in the contract
    error InitialCollateralRatioError(string message, uint256 minimumDepositAmount);
    
    /// state variables declared
    DepositorCoin public depositorCoin;
    Oracle public oracle;
    uint256 public feeRatePercentage;
    WadLib.Wad public dpcInUsdPrice;
    uint256 public constant INITIAL_COLLATERAL_RATIO_PERCENTAGE = 10;

    /// constructor takes in two arguments
    constructor(uint256 _feeRatePercentage, Oracle _oracle)
        /// calls on the constructor of the ERC20 contract and passes two string arguments 
        ERC20("StableCoin", "STC") {
        /// sets values for the feeRatePercentage
        feeRatePercentage = _feeRatePercentage;
        /// sets values for the oracle
        oracle = _oracle;
    }

    /// @notice This function allows us to mint our token by depositing ether
    function mint() public payable {

        // gets fee for minting
        uint256 fee = _getFee(msg.value);

        // substracts fee from balance to get remaining eth
        uint256 remainingEth = msg.value - fee;

        // mints stable coin to  depositor depending on eth deposited divided by oracle.getprice()
        uint256 mintStableCoinAmount = remainingEth / oracle.getPrice();

        // calls the mint function
        _mint(msg.sender, mintStableCoinAmount);
    }

    /// @notice Function allows us to burn our stable coin
    function burn(uint256 burnStableCoinAmount) external {

        int256 deficitOrSurplusInUsd = _getDeficitOrSurplusInContractInUsd();
        
        // checks if the depositor has surplus in usd balance
        require(deficitOrSurplusInUsd >= 0, "STC: Cannot burn while in deficit");

        // implements the burn function
        _burn(msg.sender, burnStableCoinAmount);

        // calculates how much eth the user is getting
        uint256 refundingEth = burnStableCoinAmount * oracle.getPrice();
        
        // gets the fee for burning
        uint256 fee = _getFee(refundingEth);

        // transfers the remaining amount after fee has been deducted
        uint256 remainingRefundingEth = refundingEth - fee;

        // tansfers the sender the remainingRefundingEth
        (bool success,) = msg.sender.call.value(remainingRefundingEth)("");
        
        // checks if transfer was successfull
        require(success, "STC: Burn refund transaction failed");
    }

    /// @notice A function that calculates fee 
    /// @return Fee
    function _getFee(uint256 ethAmount) internal returns (uint256) {

        // checks if the depositor address is not a zero address
        // and the depositorcoin total supply is greater than zero
        bool hasDepositors = address(depositorCoin) != address(0) && 
            depositorCoin.totalSupply() > 0;
        
        // if it doesn't have depositor return 0
        if (!hasDepositors) {
            return 0;
        }

        // returns the feeRatePercentage
        return (feeRatePercentage * ethAmount) / 100;
    }

    // functions that implements the overcollateratization
    function depositCollateralBuffer() external payable {

        int256 deficitOrSurplusInUsd = _getDeficitOrSurplusInContractInUsd();

        // checks the deficit or surplus <= 0
        if (deficitOrSurplusInUsd <= 0) {

            // converts the variable to positive
            int256 deficitInUsd = uint256(deficitOrSurplusInUsd * -1);
            
            // gets oracle price
            uint256 usdInEthPrice = oracle.getPrice();

            // converts deficitinusd to deficitin eth
            uint256 deficitInEth = deficitInUsd / usdInEthPrice;

            // checks the requiredinitialsurplusinusd
            uint256 requiredInitialSurplusInUsd = (INITIAL_COLLATERAL_RATIO_PERCENTAGE * 
            totalSupply) / 100;
            
            // converts the requiredinitialsurplusinusd to eth
            uint256 requiredInitialSurplusInEth = requiredInitialSurplusInUsd / usdInEthPrice;

            // checks our requiredinitialsurplusineth
            if (msg.value < deficitInEth + requiredInitialSurplusInEth) {
                uint256 minimumDepositAmount = deficitInEth + requiredInitialSurplusInEth;
                revert InitialCollateralRatioError("STC: Initial collateral ratio not met, minimum is " +
                minimumDepositAmount 
                );
            }

            // calculates new initial surplus in eth
            uint256 newInitialSurplusInEth = msg.value - deficitInEth;
            
            // converts to usd
            uint256 newInitialSurplusInUsd = newInitialSurplusInEth * usdInEthPrice;

            // deploy new depositor coin
            depositorCoin = new DepositorCoin();

            // declares the variable mintDepositorCoinAmount
            uint256 mintDepositorCoinAmount = newInitialSurplusInUsd;

            // mints the depositor the amount
            depositorCoin.mint(msg.sender, mintDepositorCoinAmount);

            return;
        }

        // converts to positive
        uint256 surplusInUsd = uint256(deficitOrSurplusInUsd);

        WadLib.Wad dpcInUsdPrice = _getDPCinUsdPrice(surplusInUsd);

        uint256 mintDepositorCoinAmount = ((msg.value.mulwad(dpcInUsdPrice)) / oracle.getPrice());

        // mints to the sender
        depositorCoin.mint(msg.sender, mintDepositorCoinAmount);
    }

    // functions that withdraws collateral to the sender
    function withdrawCollateralBuffer(uint256 burnDepositorCoinAmount) external {
        
        // checks if the sender balance is greater than the amount passed
        require(
        depositorCoin.balanceOf(msg.sender) >= burnDepositorCoinAmount,
        "STC: Sender has insuffient DPC funds");

        // implement the burn function
        depositorCoin.burn(msg.sender, burnDepositorCoinAmount);

        // checks deficitorsurplusinusd
        int256 deficitOrSurplusInUsd = _getDeficitOrSurplusInContractInUsd();
        
        // requires that the value is positive
        require(deficitOrSurplusInUsd >= 0, "STC: No funds to withdraw");

        // converts back to uint256 since it is a positive number
        uint256 surplusInUsd = uint256(deficitOrSurplusInUsd);

        // getDPCinusdprice
        WadLib.Wad dpcInUsdPrice = _getDPCinUsdPrice(surplusInUsd);

        // calculates price to be refunded
        uint256 refundingUsd = burnDepositorCoinAmount.mulWad(dpcInUsdPrice);
        
        // convert back to eth
        uint256 refundingEth = refundingUsd / oracle.getPrice();

        // send it back to the sender
        (bool success,) = msg.sender.call{ value: refundingEth }("");

        // checks if it was successfull
        require(success, "STC: Withdraw refund transaction failed");
    }

    // function for depositor to depositor to the contract 
    function _getDeficitOrSurplusInContractInUsd() private view returns (int256) {

        // get the surplus by subtracting sender balance from contract balance
        uint256 ethContractBalanceInUsd = (address(this).balance - msg.value) *
         oracle.getPrice();

        // checks how many stable coins are in supply
        uint256 totalStableCoinBalanceInUsd = totalSupply;

        //  checks of the contract is in deficit or surplus
        int256 deficitOrSurplus = int256(ethContractBalanceInUsd) - 
        int256(totalStableCoinBalanceInUsd);
        
        return deficitOrSurplus;
    }

    // function to get DPC in usd price
    function _getDPCinUsdPrice(uint256 surplusInUsd) private view returns (WadLib.Wad) 
    {
        return WadLib.fromFraction(depositorCoin.totalSupply(),SurplusInUsd);
    }
}
