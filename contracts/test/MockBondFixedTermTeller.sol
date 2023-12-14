// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import '../external/solady/ERC20.sol';
import '../external/solady/ERC1155.sol';

contract MockBondFixedTermTeller is ERC1155 {

    address public immutable token;

    uint256 public constant bondTotalSupply = 149999999999999999999927;
    uint256 public constant bondTokenId = 50041069287616932026042816520963973508955622977186811114648766172172485699723;

    constructor (
        address token_
    ) {
        token = token_;
    }

    function depositUnderlying() external {
        ERC20(token).transferFrom(msg.sender, address(this), bondTotalSupply);
        _mint(msg.sender, bondTokenId, bondTotalSupply, bytes(""));
    }

    /// @notice          Redeem a fixed-term bond token for the underlying token (bond token must have matured)
    /// @param tokenId_  ID of the bond token to redeem
    /// @param amount_   Amount of bond token to redeem
    function redeem(uint256 tokenId_, uint256 amount_) external {
        _burn(msg.sender, tokenId_, amount_);
        ERC20(token).transfer(msg.sender, amount_);
    }

    function uri(uint256 id) public pure override returns (string memory) {
        id;
        return "";
    }
}