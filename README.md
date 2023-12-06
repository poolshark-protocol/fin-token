# 🦈 Poolshark FIN Token 🦈
A fungible token to distribute on-chain rewards for Poolshark.

This token is an implementation of xERC20 using Solady's ERC-20 as a base. 

This follows the specification detailed in the [ERC-7281 Ethereum Magicians post](https://ethereum-magicians.org/t/erc-7281-sovereign-bridged-tokens/14979).

### What's New 
xERC20s are natively crosschain without compromises. This makes your token:

* Transferrable across chains with no slippage.
* Deployed and fully controlled by you, the token issuer, including the ability to set rate limits on a per-bridge basis.

### Installation
```
git clone https://github.com/poolshark-protocol/fin-token
cd fin-token
yarn install
```

### Testing
Tests can be run via the following commands.

Only Hardhat is supported for now, with Foundry support soon to follow.
```
yarn clean
yarn compile
yarn test
```

Contracts can be deployed onto Arbitrum Goerli using the deploy script:
```
npx hardhat deploy-fintoken --network arb_goerli
```

#### Supported Interfaces

_ERC-20: Token Standard_

_ERC-2612: Permit Extension for EIP-20 Signed Approvals_

_ERC-7281: Sovereign Bridged Tokens_

#### EVM Compatibility
Some parts of this repository may not be compatible with chains with partial EVM equivalence.

Please always check and test for compatibility accordingly.

