// SPDX-License-Identifier: SSPL-1.0
pragma solidity 0.8.18;

import '../structs/PoolsharkStructs.sol';

abstract contract ILimitPoolFactory is
    PoolsharkStructs
{
    function createLimitPool(LimitPoolParams memory params)
        external
        virtual
        returns (address pool, address poolToken);

    function getLimitPool(
        address tokenIn,
        address tokenOut,
        uint16 swapFee,
        uint16 poolTypeId
    ) external view virtual returns (address pool, address poolToken);
}
