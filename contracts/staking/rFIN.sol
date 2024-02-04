// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "../interfaces/rewards/IRewardDistributor.sol";
import "../interfaces/rewards/IRewardTracker.sol";
import "../access/Governable.sol";
import "../external/solady/ERC20.sol";
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract RewardsFin is ERC20, IRewardDistributor, ReentrancyGuard, Governable {

    address public immutable override rewardToken;
    uint256 public override tokensPerInterval;
    uint256 public lastDistributionTime;
    address public rewardTracker;
    address public admin;

    event Distribute(uint256 amount);
    event TokensPerIntervalChange(uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "RewardsFin: forbidden");
        _;
    }

    constructor(
        address _rewardTracker
    ) {
        rewardToken = address(this);
        rewardTracker = _rewardTracker;
        admin = msg.sender;
    }

    /// @dev Returns the name of the token.
    function name() public pure override returns (string memory) {
        return 'Rewards FIN';
    }

    /// @dev Returns the symbol of the token.
    function symbol() public pure override returns (string memory) {
        return 'rFIN';
    }

    function setAdmin(address _admin) external onlyGov {
        admin = _admin;
    }

    // to help users who accidentally send their tokens to this contract
    function withdrawToken(address _token, address _account, uint256 _amount) external onlyGov {
        ERC20(_token).transfer(_account, _amount);
    }

    function updateLastDistributionTime() external onlyAdmin {
        lastDistributionTime = block.timestamp;
    }

    //TODO: by default use 100% APR unless overriden
    function setTokensPerInterval(uint256 _amount) external onlyAdmin {
        require(lastDistributionTime != 0, "RewardDistributor: invalid lastDistributionTime");
        IRewardTracker(rewardTracker).updateRewards();
        tokensPerInterval = _amount;
        emit TokensPerIntervalChange(_amount);
    }

    function pendingRewards() public view override returns (uint256) {
        if (block.timestamp == lastDistributionTime) {
            return 0;
        }

        uint256 timeDiff = block.timestamp - (lastDistributionTime);
        return tokensPerInterval * (timeDiff);
    }

    function distribute() external override returns (uint256) {
        require(msg.sender == rewardTracker, "RewardDistributor: invalid msg.sender");
        uint256 amount = pendingRewards();
        if (amount == 0) { return 0; }

        lastDistributionTime = block.timestamp;

        uint256 balance = ERC20(rewardToken).balanceOf(address(this));
        if (amount > balance) { amount = balance; }

        ERC20(rewardToken).transfer(msg.sender, amount);

        emit Distribute(amount);
        return amount;
    }
}