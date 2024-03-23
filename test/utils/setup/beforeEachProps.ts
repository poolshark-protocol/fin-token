import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { getNonce } from '../../../tasks/utils'
import {
    FIN, MockBondFixedTermTeller, TgeDeploy, VFIN,
} from '../../../typechain'
import { InitialSetup } from './initialSetup'

export interface BeforeEachProps {
    //shared
    finToken: FIN
    vFin: VFIN
    mockTeller: MockBondFixedTermTeller
    tgeDeploy: TgeDeploy
    admin: SignerWithAddress
    alice: SignerWithAddress
    bob: SignerWithAddress
    carol: SignerWithAddress
}

export class GetBeforeEach {
    private initialSetup: InitialSetup
    private nonce: number

    constructor() {
        this.initialSetup = new InitialSetup()
    }

    public async getBeforeEach() {
        hre.props = this.retrieveProps()
        const signers = await ethers.getSigners()
        hre.props.admin = signers[0]
        hre.props.alice = signers[0]
        if (hre.network.name == 'hardhat') {
            hre.props.bob = signers[1]
            hre.carol = signers[2]
        }
        hre.nonce = await getNonce(hre, hre.props.alice.address)
        this.nonce = await this.initialSetup.initialFinTokenSetup()
    }

    public retrieveProps(): BeforeEachProps {
        //shared
        let finToken: FIN
        let vFin: VFIN
        let mockTeller: MockBondFixedTermTeller
        let tgeDeploy: TgeDeploy
        let admin: SignerWithAddress
        let alice: SignerWithAddress
        let bob: SignerWithAddress
        let carol: SignerWithAddress

        return {
            //shared
            finToken,
            vFin,
            mockTeller,
            tgeDeploy,
            admin,
            alice,
            bob,
            carol,
        }
    }
}
