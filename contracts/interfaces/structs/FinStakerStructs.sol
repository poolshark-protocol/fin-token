// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.18;

interface FinStakerStructs {
    struct RewardEpoch {
        address token;
        uint128 totalAmount;
        uint96 totalPoints;
        uint32 timestamp;
    }

    struct FinStake {
        uint96 amount;
        uint96 points;
        uint32 lastTimestamp;
        uint24 lastRewardEpoch;
    }

    struct StakeFinParams {
        address to;
        uint96 amount;
    }

    struct AddRewardParams {
        address token;
        uint128 amount;
    }
}