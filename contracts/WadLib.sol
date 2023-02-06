// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// library for fixed point numbers
library WadLib {

    // multiplier defined
    uint256 public constant MULTIPLIER = 10**18;

    // defines your type value
    type Wad is uint256;

    // function for the multiplier
    function mulWad(uint256 number, Wad wad) internal pure returns (uint256)
    {
        return (number * Wad.unwrap(wad)) / MULTIPLIER;
    }

    // function for the divisor
    function divWad(uint256 number, Wad wad) internal pure returns (uint256)
     {
        return (number * MULTIPLIER) / Wad.unwrap(wad);
     }

    // function for dividing the numerator by the denominator
     function fromFraction(uint256 numerator, uint256 denominator) internal pure returns (Wad)
    {
        if (numerator == 0) {
            return Wad.wrap(0);
        }

        return Wad.wrap((numerator * MULTIPLIER) / denominator);
    }
}