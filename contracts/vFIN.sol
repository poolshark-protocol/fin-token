// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {ERC1155} from './external/solady/ERC1155.sol';
import {ERC721} from './external/solady/ERC721.sol';
import {ERC20} from './external/solady/ERC20.sol';
import {Ownable} from '../lib/openzeppelin-contracts/contracts/access/Ownable.sol';
import {SafeCast} from './libraries/utils/SafeCast.sol';
import {IBondFixedTermTeller} from './interfaces/bond/IBondFixedTermTeller.sol';

contract vFIN is ERC721, Ownable {

  using SafeCast for uint256;

  /**
   * @notice The max total supply of the token
   */
  address public immutable finAddress;

  /**
   * @notice The minter of the FIN bond
   */
  address public immutable tellerAddress;

  /**
   * @notice The token id of the FIN bond
   */
  uint256 public immutable tellerTokenId;

  /**
   * @notice The total FIN amount to be vested
   */
  uint256 public immutable vestAmount;

  /**
   * @notice The start block.timestamp of the vest
   */
  uint256 public immutable vestStartTime;

  /**
   * @notice The end block.timestamp of the vest
   */
  uint256 public immutable vestEndTime;

  struct VestState {
    uint32 idNext;
    bool started;
  }

  struct VestPosition {
    uint128 amount;
    uint32 lastClaimTimestamp;
  }

  VestState public vestState;
  
  mapping(uint256 => VestPosition) public vestPositions;

  /**
   * @notice Constructs the initial config of the vFIN contract
   *
   * @param _owner The owner which can redeem exchanged bonds
   * @param _vestAmount The total amount of FIN vested
   */
  constructor(
    address _owner,
    address _finAddress,
    address _tellerAddress,
    uint256 _tellerTokenId,
    uint256 _vestAmount,
    uint32 _vestStartTime,
    uint32 _vestEndTime
  ) ERC721() {
    _transferOwnership(_owner);
    owner = _owner;
    finAddress = _finAddress;
    tellerAddress = _tellerAddress;
    tellerTokenId = _tellerTokenId;
    vestAmount = _vestAmount;
    vestStartTime = _vestStartTime;
    vestEndTime = _vestEndTime;
    vestState.idNext = 1;
  }
    
  /// @dev Returns the name of the token.
  function name() public pure override returns (string memory) {
      return 'Vested FIN';
  }

  /// @dev Returns the symbol of the token.
  function symbol() public pure override returns (string memory) {
      return 'vFIN';
  }

  function tokenURI(uint256 id) public pure override returns (string memory) {}

  function createLinearVest() external onlyOwner() {
    // only create vest once
    if (vestState.started) require(false, "VestingAlreadyStarted()");
    // transfer from owner
    ERC20(finAddress).transferFrom(msg.sender, address(this), vestAmount);
    // start vest
    vestState.started = true;
  }

  function exchangeBond(address to, uint256 amount, uint32 positionId) external {
    // Checks: revert if vest not started
    if (!vestState.started) require(false, "VestingNotStarted()");
    // Interactions: transfer FIN bond from user
    ERC1155(tellerAddress).safeTransferFrom(
      msg.sender,
      address(this),
      tellerTokenId,
      amount,
      bytes("")
    );
    VestPosition memory vestPosition;

    if (positionId == 0) {
      // mint new position
      positionId = vestState.idNext;
      _mint(to, vestState.idNext);
      ++vestState.idNext;
      vestPosition.lastClaimTimestamp = uint32(vestStartTime);
    } else {
      // load existing position
      if (ownerOf(positionId) != to)
        require (false, "PositionOwnerMismatch()");
      vestPosition = vestPositions[positionId];
    }

    // calculate initial vested amount
    uint256 vestedAmount = amount
                            * (block.timestamp - vestStartTime)
                            / (vestEndTime - vestStartTime);
                  
    if (vestPosition.amount > 0) {
      // calculate previous vested amount 
      vestedAmount += vestPosition.amount
                        * (block.timestamp - vestPosition.lastClaimTimestamp)
                        / (vestEndTime - vestStartTime);
    }

    // transfer out vested amount
    ERC20(finAddress).transfer(to, vestedAmount);

    // update vest
    vestPosition.amount += amount.toUint128();
    vestPosition.lastClaimTimestamp = uint32(block.timestamp);

    // save to storage
    vestPositions[positionId] = vestPosition;
  }

  function claim(address to, uint32 positionId) external {
    // Checks: revert if vest not started
    if (!vestState.started) require(false, "VestingNotStarted()");
    // Checks: revert if owner not msg.sender
    if (ownerOf(positionId) != msg.sender)
        require (false, "PositionOwnerMismatch()");

    // load vested position
    VestPosition memory vestPosition = vestPositions[positionId];

    // calculate vested amount
    uint256 vestedAmount = vestPosition.amount
                            * (block.timestamp - vestPosition.lastClaimTimestamp)
                            / (vestEndTime - vestStartTime);

    // Effects: update vest
    vestPosition.lastClaimTimestamp = uint32(block.timestamp);

    // Effects: save to storage
    vestPositions[positionId] = vestPosition;

    // Interactions: transfer out vested amount
    ERC20(finAddress).transfer(to, vestedAmount);
  }

  function redeem() external onlyOwner() {
    // Checks: revert if vest not started
    if (!vestState.started) require(false, "VestingNotStarted()");

    uint256 finBondBalance = ERC1155(tellerAddress).balanceOf(address(this), tellerTokenId);

    if (finBondBalance == 0) require(false, "FINBondBalanceZero()");

    IBondFixedTermTeller(tellerAddress).redeem(tellerTokenId, finBondBalance);
  }

  function withdraw() external onlyOwner() {
    // Checks: revert if vest not started
    if (!vestState.started) require(false, "VestingNotStarted()");

    uint256 finBondBalance = ERC1155(tellerAddress).balanceOf(address(this), tellerTokenId);

    if (finBondBalance == 0) require(false, "FINBondBalanceZero()");

    ERC1155(tellerAddress).safeTransferFrom(address(this), owner, tellerTokenId, finBondBalance, bytes(""));
  }

  function viewClaim(uint32 positionId) external view returns (uint256 vestedAmount) {

    // load vested position
    VestPosition memory vestPosition = vestPositions[positionId];

    // calculate vested amount
    vestedAmount = vestPosition.amount
                    * (block.timestamp - vestPosition.lastClaimTimestamp)
                    / (vestEndTime - vestStartTime);
  }
}
