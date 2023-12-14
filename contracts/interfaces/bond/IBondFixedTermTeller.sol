// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import '../../external/solady/ERC20.sol';

interface IBondFixedTermTeller {
    // Info for bond token
    struct TokenMetadata {
        bool active;
        ERC20 underlying;
        uint8 decimals;
        uint48 expiry;
        uint256 supply;
    }
    /// @notice          Redeem a fixed-term bond token for the underlying token (bond token must have matured)
    /// @param tokenId_  ID of the bond token to redeem
    /// @param amount_   Amount of bond token to redeem
    function redeem(uint256 tokenId_, uint256 amount_) external;
}