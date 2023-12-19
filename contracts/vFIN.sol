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
   * @notice The total supply of the FIN bond
   */
  uint256 public constant BOND_TOTAL_SUPPLY = 149999999999999999999927;
  
  /**
   * @notice The token id of the FIN bond
   */
  uint256 public constant BOND_TOKEN_ID = 50041069287616932026042816520963973508955622977186811114648766172172485699723;

  /**
   * @notice The max total supply of the token
   */
  address public immutable finAddress;

  /**
   * @notice The minter of the FIN bond
   */
  address public immutable tellerAddress;

  /**
   * @notice The start block.timestamp of the vest
   */
  uint256 public constant vestStartTime = 1702314000; // Dec 11th, 2023 @ 5pm UTC

  /**
   * @notice The end block.timestamp of the vest
   */
  uint256 public immutable vestEndTime = 1707498000; // Feb 9th, 2024 @ 5pm UTC

  struct VestState {
    uint32 idNext;
    uint32 totalBurned;
    bool started;
    bool ended;
    bool withdrawn;
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
   */
  constructor(
    address _owner,
    address _finAddress,
    address _tellerAddress
  ) ERC721() {
    _transferOwnership(_owner);
    finAddress = _finAddress;
    tellerAddress = _tellerAddress;
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

  function startLinearVest() external onlyOwner() {
    // only create vest once
    if (vestState.started) require(false, "VestingAlreadyStarted()");
    // transfer from owner
    ERC20(finAddress).transferFrom(msg.sender, address(this), BOND_TOTAL_SUPPLY);
    // start vest
    vestState.started = true;
  }

  function exchangeBond(uint256 amount, uint32 positionId) external {
    // Checks: revert if vest not started
    if (!vestState.started) {
      require(false, "VestingNotStarted()");
    } else if (block.timestamp >= vestEndTime) {
      require(false, "VestingAlreadyComplete()");
    } else if (amount == 0) {
      require(false, "VestingZeroBonds()");
    }
    // Interactions: transfer FIN bond from user
    ERC1155(tellerAddress).safeTransferFrom(
      msg.sender,
      address(this),
      BOND_TOKEN_ID,
      amount,
      bytes("")
    );

    VestPosition memory vest;

    if (positionId == 0) {
      // mint new position
      positionId = vestState.idNext;
      _mint(msg.sender, vestState.idNext);
      ++vestState.idNext;
      vest.lastClaimTimestamp = uint32(vestStartTime);
    } else {
      // load existing position
      if (ownerOf(positionId) != msg.sender)
        require (false, "PositionOwnerMismatch()");
      vest = vestPositions[positionId];
    }

    // calculate initial vested amount
    uint256 vestedAmount = _calculateVestedInitial(amount);
                  
    if (vest.amount > 0) {
      // calculate previous vested amount 
      vestedAmount += _calculateVestedAmount(vest);
    }

    // transfer out vested amount
    ERC20(finAddress).transfer(msg.sender, vestedAmount);

    // Effects: update vest
    vest.amount += amount.toUint128();
    uint256 vestCurrentTime = block.timestamp <= vestEndTime
                                ? block.timestamp
                                : vestEndTime;
    vest.lastClaimTimestamp = uint32(vestCurrentTime);

    // save to storage
    vestPositions[positionId] = vest;
  }

  function claim(uint32 positionId) external {
    // Checks: revert if vest not started
    if (!vestState.started) require(false, "VestingNotStarted()");
    // Checks: revert if owner not msg.sender
    if (ownerOf(positionId) != msg.sender)
        require (false, "PositionOwnerMismatch()");

    // load vested position
    VestPosition memory vest = vestPositions[positionId];

    // calculate vested amount
    uint256 vestedAmount = _calculateVestedAmount(vest);

    // Effects: update vest
    uint256 vestCurrentTime = block.timestamp <= vestEndTime
                                ? block.timestamp
                                : vestEndTime;
    vest.lastClaimTimestamp = uint32(vestCurrentTime);

    // Effects: save to storage
    vestPositions[positionId] = vest;

    // Effects: burn NFT after full vest
    if (uint32(block.timestamp) >= vestEndTime) {
      _burn(positionId);
      ++vestState.totalBurned;
    }

    // Interactions: transfer out vested amount
    ERC20(finAddress).transfer(msg.sender, vestedAmount);
  }

  function withdraw(bool redeem) external onlyOwner() {
    // Checks: revert if vest incomplete
    if (!vestState.started || block.timestamp <= vestEndTime)
      require(false, "VestingPeriodIncomplete()");

    // Checks: get FIN bond balance
    uint256 finBondBalance = ERC1155(tellerAddress).balanceOf(address(this), BOND_TOKEN_ID);

    if (finBondBalance > 0) { 
      // Interactions: redeem bond
      if (redeem) {
        IBondFixedTermTeller(tellerAddress).redeem(BOND_TOKEN_ID, finBondBalance);
        ERC20(finAddress).transfer(owner, finBondBalance);
      } else {
        ERC1155(tellerAddress).safeTransferFrom(address(this), owner, BOND_TOKEN_ID, finBondBalance, bytes(""));
      }
    }

    // Interactions: transfer remaining FIN out
    if (!vestState.withdrawn) {
      uint256 finToOwner = (BOND_TOTAL_SUPPLY - finBondBalance);
      ERC20(finAddress).transfer(owner, finToOwner);
      vestState.withdrawn = true;
    }
  }

  function viewClaim(uint32 positionId) external view returns (uint256 vestedAmount) {
    // load vested position and calculate vested amount
    return _calculateVestedAmount(vestPositions[positionId]);
  }

  function totalSupply() external view returns (uint256 supply) {
    return vestState.idNext - vestState.totalBurned - 1;
  }

  function supportsInterface(bytes4 interfaceId)
      public
      pure
      override
      returns (bool)
  {
      return
          interfaceId == 0x01ffc9a7 || // ERC-165 support
          interfaceId == 0x80ac58cd || // ERC-271 support
          interfaceId == 0x5b5e139f || // ERC-721Metadata support
          interfaceId == 0xd9b67a26;   // ERC-1155 support
  }

  function onERC1155Received(
      address operator,
      address from,
      uint256 id,
      uint256 value,
      bytes calldata data
  ) external pure returns (bytes4) {
    operator; from; id; value; data;
    return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
  }

  function _calculateVestedAmount(VestPosition memory vest) private view returns (uint256 vestedAmount) {
    
    // Checks: vest ends at vestEndTime
    uint256 vestCurrentTime = block.timestamp <= vestEndTime
                                ? block.timestamp
                                : vestEndTime;

    // calculate vested amount
    vestedAmount = vest.amount
                    * (vestCurrentTime - vest.lastClaimTimestamp)
                    / (vestEndTime - vestStartTime);
  }

  function _calculateVestedInitial(uint256 amount) private view returns (uint256 vestedInitial) {
    // Checks: vest ends at vestEndTime
    uint256 vestCurrentTime = block.timestamp <= vestEndTime
                                ? block.timestamp
                                : vestEndTime;

    // calculate vested amount
    vestedInitial = amount
                    * (vestCurrentTime - vestStartTime)
                    / (vestEndTime - vestStartTime);
  }
}
