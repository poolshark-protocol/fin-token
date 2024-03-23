// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "../FIN.sol";
import "../interfaces/staking/IRangeStaker.sol";
import "../interfaces/staking/ILimitStaker.sol";
import "../interfaces/IPoolsharkRouter.sol";
import "../interfaces/structs/PoolsharkStructs.sol";

contract TgeDeploy is PoolsharkStructs {

    struct TgeDeployLocals {
        LimitPoolParams poolParams;
        MintRangeParams rangeParams1;
        MintRangeParams rangeParams2;
        MintLimitParams limitParams1;
        FIN fin;
        IPoolsharkRouter router;
        address wethAddress;
        address tgePool;
        uint256 finBalance;
        bool finIsToken0;
    }

    struct MintRangeInputData {
        address staker;
    }

    struct MintLimitInputData {
        address staker;
    }

    constructor() {}

    function execute(
        address _owner,
        address _router,
        address _finToken,
        address _rangeStaker,
        address _limitStaker
    ) external {
        // deploy FIN token with address(this) as owner
        TgeDeployLocals memory locals;
        locals.fin = FIN(_finToken);
        locals.router = IPoolsharkRouter(_router);
        locals.wethAddress = locals.router.wethAddress();
        locals.finIsToken0 = address(locals.fin) < locals.wethAddress;

        // mint 3mil FIN to address(this)
        locals.fin.mint(address(this), 1_500_000e18);
        locals.fin.approve(_router, 1_500_000e18);

        // 1/3800 lower
        // 10/3800 upper
        // OR
        // 3800/10 lower
        // 3800/1 upper

        // token0 - 0x1..
        // token1 - 0xa..

        // createAndMint 1st range position to _owner
        locals.poolParams = LimitPoolParams({
            tokenIn: locals.wethAddress,
            tokenOut: address(locals.fin),
            startPrice: locals.finIsToken0 ? 1284405785637015839960960365    // price at -82410; 3805 FIN per ETH
                                           : 4887164014348845271051454191298, // price at 82410; 3805 FIN per ETH
            swapFee: 3000,
            poolTypeId: 2
        });

        MintRangeInputData memory rangeCallbackData = MintRangeInputData({
            staker: _rangeStaker
        });

        MintLimitInputData memory limitCallbackData = MintLimitInputData({
            staker: _limitStaker
        });

        // $1 to $6
        locals.rangeParams1 = MintRangeParams({
            to: _owner,
            lower: locals.finIsToken0 ? -82410
                                      : int24(64500),
            upper: locals.finIsToken0 ? -64500
                                      : int24(82410),
            positionId: 0,
            amount0: locals.    finIsToken0 ? 150_000e18
                                        : 0,
            amount1: locals.finIsToken0 ? 0
                                        : 150_000e18,
            callbackData: abi.encode(rangeCallbackData)
        });

        // $2 to $4
        locals.rangeParams2 = MintRangeParams({
            to: _owner,
            lower: locals.finIsToken0 ? -75510
                                      : int24(68580),
            upper: locals.finIsToken0 ? -68580
                                      : int24(75510),
            positionId: 0,
            amount0: locals.finIsToken0 ? 350_000e18
                                        : 0,
            amount1: locals.finIsToken0 ? 0
                                        : 350_000e18,
            callbackData: abi.encode(rangeCallbackData)
        });

        PoolsharkStructs.MintRangeParams[] memory mintRangeParams = new PoolsharkStructs.MintRangeParams[](2);
        mintRangeParams[0] = locals.rangeParams1;
        mintRangeParams[1] = locals.rangeParams2;

        // $3 to $5
        locals.limitParams1 = MintLimitParams({
            to: _owner,
            lower: locals.finIsToken0 ? -71460
                                      : int24(66330),
            upper: locals.finIsToken0 ? -66330
                                      : int24(71460),
            positionId: 0,
            amount: 1_000_000e18,
            mintPercent: 0,
            zeroForOne: locals.finIsToken0,
            callbackData: abi.encode(limitCallbackData)
        });

        PoolsharkStructs.MintLimitParams[] memory mintLimitParams = new PoolsharkStructs.MintLimitParams[](1);
        mintLimitParams[0] = locals.limitParams1;

        (
            locals.tgePool,
        ) = locals.router.createLimitPoolAndMint(
            locals.poolParams,
            mintRangeParams,
            mintLimitParams
        );

        // stake range postions
        IRangeStaker(_rangeStaker).stakeRange(
            StakeRangeParams({to: _owner, pool: locals.tgePool, positionId: 1})
        );

        IRangeStaker(_rangeStaker).stakeRange(
            StakeRangeParams({to: _owner, pool: locals.tgePool, positionId: 2})
        );

        // stake limit position
        ILimitStaker(_limitStaker).stakeLimit(
            StakeLimitParams({to: _owner, pool: locals.tgePool, positionId: 3, zeroForOne: locals.finIsToken0})
        );

        // transfer FIN ownership to _owner
        locals.fin.transferOwnership(_owner);

        locals.finBalance = locals.fin.balanceOf(address(this));

        if (locals.finBalance > 0) {
            locals.fin.transfer(_owner, locals.finBalance);
        }
    }
}
