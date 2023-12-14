import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { expect } from "chai"
import { BigNumber } from "ethers"
import { gBefore } from "../utils/hooks.test"
import { BN_ZERO, ZERO_ADDRESS, bondTokenId, bondTotalSupply, emptyBytes } from "../utils/contracts/vfin"
import { parseUnits } from "ethers/lib/utils"
import { time } from "@nomicfoundation/hardhat-network-helpers";

describe('vFIN Tests', function () {
    let tokenAmount: string
    let tokenAmountBn: BigNumber
    let token0Decimals: number
    let token1Decimals: number
    let minPrice: BigNumber
    let maxPrice: BigNumber

    let alice: SignerWithAddress
    let bob: SignerWithAddress
    let carol: SignerWithAddress

    ////////// DEBUG FLAGS //////////
    let debugMode           = false
    let balanceCheck        = false
    let deltaMaxBeforeCheck = false
    let deltaMaxAfterCheck  = false
    let latestTickCheck     = false

    //every test should clear out all liquidity

    before(async function () {
        await gBefore()
        let currentBlock = await ethers.provider.getBlockNumber()

        alice = hre.props.alice
        bob = hre.props.bob
        carol = hre.props.carol

        // START LINEAR VEST

        // mint FIN
        let txn = await hre.props.finToken.mint(
            hre.props.admin.address,
            BigNumber.from(bondTotalSupply)
        )
        await txn.wait();
        hre.nonce += 1;
        
        // approve vFIN contract
        txn = await hre.props.finToken.approve(
            hre.props.vFin.address,
            BigNumber.from(bondTotalSupply)
        )
        await txn.wait();
        hre.nonce += 1;
        
        // mint FIN token to admin
        txn = await hre.props.vFin
            .connect(hre.props.alice).startLinearVest()
        await txn.wait();
        hre.nonce += 1;
        
        // revert since vest already started
        await expect(
            hre.props.vFin
              .connect(hre.props.admin)
              .startLinearVest()
        ).to.be.revertedWith('VestingAlreadyStarted()')
    })

    it('Should revert on onlyOwner', async function () {
        await expect(
            hre.props.vFin
              .connect(hre.props.bob)
              .startLinearVest()
        ).to.be.revertedWith('Ownable: caller is not the owner')
        
        // redeem bonds
        await expect(
            hre.props.vFin
              .connect(hre.props.bob)
              .redeem()
        ).to.be.revertedWith('Ownable: caller is not the owner')
        
        // withdraw bonds
        await expect(
            hre.props.vFin
              .connect(hre.props.bob)
              .withdraw()
        ).to.be.revertedWith('Ownable: caller is not the owner')
    })

    it('Should exchange bonds for vFIN', async function () {
        await expect(
            hre.props.vFin
              .connect(hre.props.bob)
              .exchangeBond(parseUnits("100", 18), 0)
        ).to.be.revertedWith('NotOwnerNorApproved()')
        
        let txn = await hre.props.mockTeller.connect(hre.props.bob).setApprovalForAll(
            hre.props.vFin.address,
            true
        )
        await txn.wait();

        await expect(
            hre.props.vFin
              .connect(hre.props.bob)
              .exchangeBond(parseUnits("100", 18), 0)
        ).to.be.revertedWith('InsufficientBalance()')

        // transfer bonds to bob
        txn = await hre.props.mockTeller.connect(hre.props.admin).safeTransferFrom(
            hre.props.admin.address,
            hre.props.bob.address,
            BigNumber.from(bondTokenId),
            parseUnits("100", 18),
            emptyBytes
        )
        await txn.wait();

        const expectedPositionId = (await hre.props.vFin.vestState()).idNext
        expect(await hre.props.finToken.balanceOf(hre.props.bob.address)).to.be.equal(BN_ZERO)

        // bob exchange bonds for vFIN
        txn = await hre.props.vFin
        .connect(hre.props.bob)
        .exchangeBond(parseUnits("100", 18), 0)
        await txn.wait()

        // bob owns the vFIN NFT
        expect(await hre.props.vFin.ownerOf(expectedPositionId)).to.be.equal(hre.props.bob.address)

        // bob has no bond balance
        expect(await hre.props.mockTeller.balanceOf(hre.props.bob.address, bondTokenId)).to.be.equal(BN_ZERO)

        // vFIN contract has 100 bonds now 
        expect(await hre.props.mockTeller.balanceOf(hre.props.vFin.address, bondTokenId)).to.be.equal(parseUnits("100", 18))
        
        expect(await hre.props.finToken.balanceOf(hre.props.bob.address)).to.not.be.equal(BN_ZERO)
        
        // vest more bonds with same positionId

        // transfer bonds to bob
        txn = await hre.props.mockTeller.connect(hre.props.admin).safeTransferFrom(
            hre.props.admin.address,
            hre.props.bob.address,
            BigNumber.from(bondTokenId),
            parseUnits("100", 18),
            emptyBytes
        )
        await txn.wait();

        // bob exchanges more bonds
        txn = await hre.props.vFin
        .connect(hre.props.bob)
        .exchangeBond(parseUnits("100", 18), expectedPositionId)
        await txn.wait()

        // bob owns the vFIN NFT
        expect(await hre.props.vFin.ownerOf(expectedPositionId)).to.be.equal(hre.props.bob.address)
        await expect(
            hre.props.vFin.ownerOf(expectedPositionId + 1)
        ).to.be.revertedWith('TokenDoesNotExist()')

        // bob has no bond balance
        expect(await hre.props.mockTeller.balanceOf(hre.props.bob.address, bondTokenId)).to.be.equal(BN_ZERO)

        // vFIN contract has 100 bonds now 
        expect(await hre.props.mockTeller.balanceOf(hre.props.vFin.address, bondTokenId)).to.be.equal(parseUnits("200", 18))
        
        expect(await hre.props.finToken.balanceOf(hre.props.bob.address)).to.not.be.equal(BN_ZERO)
    })

    it('Should advance time and claim more FIN', async function () {
        // advance time by one week
        await time.increase(604800);

        expect(await hre.props.vFin.viewClaim(1)).to.be.equal(BigNumber.from('23333333333333333333'))

        await expect(
            hre.props.vFin.claim(1)
        ).to.be.revertedWith('PositionOwnerMismatch()')
     
        let txn = await hre.props.vFin.connect(hre.props.bob).claim(1)
        await txn.wait();
    })
    // view claim

    // claim

    // redeem
    it('Should advance time to end of vest and claim all FIN', async function () {
        // advance time by 8 weeks
        await time.increase(604800 * 10);

        const finBalanceBefore = await hre.props.finToken.balanceOf(hre.props.bob.address)
        const finClaim = (await hre.props.vFin.viewClaim(1))

        console.log(finClaim.add(finBalanceBefore).toString())

        await expect(
            hre.props.vFin.claim(1)
        ).to.be.revertedWith('PositionOwnerMismatch()')

        // cannot exchange bond after vesting complete
        await expect(
            hre.props.vFin.exchangeBond(parseUnits('100', 18), 1)
        ).to.be.revertedWith('VestingAlreadyComplete()')
     
        let txn = await hre.props.vFin.connect(hre.props.bob).claim(1)
        await txn.wait();

        const finBalanceAfter = await hre.props.finToken.balanceOf(hre.props.bob.address)
        console.log(finBalanceAfter.toString())
        // balanceBefore + claim = balanceAfter
        expect((finBalanceBefore).add(finClaim)).to.be.equal(finBalanceAfter)
    })

    it('Should redeem all FIN bonds as the owner', async function () {
        // advance time by 8 weeks
        await time.increase(604800 * 10);

        const finBalanceBefore = await hre.props.finToken.balanceOf(hre.props.admin.address)
        
        await hre.props.vFin.redeem()

        const finBalanceAfter = await hre.props.finToken.balanceOf(hre.props.admin.address)

        console.log('fin balance change:', finBalanceBefore.toString(), finBalanceAfter.toString())
        expect(finBalanceAfter).to.be.equal(bondTotalSupply)
    })

    // withdraw
    // ensure constantly claiming does not pay out too much
    // transfer NFT and claim from new owner
    // try to redeem before end of vesting

})