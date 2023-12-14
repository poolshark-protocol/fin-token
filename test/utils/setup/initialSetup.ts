import { BigNumber } from 'ethers'
import { SUPPORTED_NETWORKS } from '../../../scripts/constants/supportedNetworks'
import { DeployAssist } from '../../../scripts/util/deployAssist'
import { ContractDeploymentsKeys } from '../../../scripts/util/files/contractDeploymentKeys'
import { ContractDeploymentsJson } from '../../../scripts/util/files/contractDeploymentsJson'
import { FIN__factory, MockBondFixedTermTeller__factory, VFIN__factory } from '../../../typechain'
import { ZERO_ADDRESS } from '../contracts/vfin'

// import {abi as factoryAbi} from '../../../artifacts/contracts/LimitPoolFactory.sol/LimitPoolFactory.json'
// import { keccak256 } from 'ethers/lib/utils'

export class InitialSetup {
    private token0Decimals = 18
    private token1Decimals = 18
    private deployAssist: DeployAssist
    private contractDeploymentsJson: ContractDeploymentsJson
    private contractDeploymentsKeys: ContractDeploymentsKeys
    private constantProductString: string

    /// DEPLOY CONFIG
    private deployTokens = true
    private deployVesting = true

    private owner = {
        'hardhat': '0xBd5db4c7D55C086107f4e9D17c4c34395D1B1E1E',
        'scrollSepolia': '0xBd5db4c7D55C086107f4e9D17c4c34395D1B1E1E',
        'arb_goerli': '0xBd5db4c7D55C086107f4e9D17c4c34395D1B1E1E',
        'arb_one': '0xf37A475c178dfbEC96088FA7904a861336002c6a',
    }

    private fixedTermTeller = {
        'hardhat': ZERO_ADDRESS,
        'scrollSepolia': ZERO_ADDRESS, // no deployment
        'arb_goerli': '0x007F7735baF391e207E3aA380bb53c4Bd9a5Fed6',
        'arb_one': '0x007F7735baF391e207E3aA380bb53c4Bd9a5Fed6',
    }

    private bondTotalSupply = "149999999999999999999927";

    constructor() {
        this.deployAssist = new DeployAssist()
        this.contractDeploymentsJson = new ContractDeploymentsJson()
        this.contractDeploymentsKeys = new ContractDeploymentsKeys()
        this.constantProductString = ethers.utils.formatBytes32String('CONSTANT-PRODUCT')
    }

    public async initialFinTokenSetup(): Promise<number> {
        const network = SUPPORTED_NETWORKS[hre.network.name.toUpperCase()]

        this.owner['hardhat']
        
        if (hre.network.name == 'hardhat') {
            //TODO: read finToken from json for deployment
            console.log('deploy token', hre.network.name)
            await this.deployAssist.deployContractWithRetry(
                network,
                //@ts-ignore
                FIN__factory,
                'finToken',
                [
                    hre.props.alice.address
                ]
            )
        }

        let tellerAddress = this.fixedTermTeller[hre.network.name]

        if (hre.network.name == 'hardhat') {

            await this.deployAssist.deployContractWithRetry(
                network,
                //@ts-ignore
                MockBondFixedTermTeller__factory,
                'mockTeller',
                [
                    hre.props.finToken.address
                ]
            )
            tellerAddress = hre.props.mockTeller.address
            // mint FIN token to admin
            let txn = await hre.props.finToken.connect(hre.props.alice).mint(
                hre.props.alice.address,
                BigNumber.from(this.bondTotalSupply)
            )
            await txn.wait();
            hre.nonce += 1;
            // approve teller
            txn = await hre.props.finToken.approve(
                tellerAddress,
                BigNumber.from(this.bondTotalSupply)
            )
            await txn.wait();
            hre.nonce += 1;
            // deposit underlying
            txn = await hre.props.mockTeller.depositUnderlying();
            await txn.wait();
            hre.nonce += 1;
        }

        await this.deployAssist.deployContractWithRetry(
            network,
            //@ts-ignore
            VFIN__factory,
            'vFIN',
            [
                this.owner[hre.network.name],
                hre.props.finToken.address,
                tellerAddress,
                0,
                4e9
            ]
        )

        return hre.nonce
    }

    // public async readLimitPoolSetup(nonce: number): Promise<number> {
    //     const token0Address = (
    //         await this.contractDeploymentsJson.readContractDeploymentsJsonFile(
    //             {
    //                 networkName: hre.network.name,
    //                 objectName: 'token0',
    //             },
    //             'readLimitPoolSetup'
    //         )
    //     ).contractAddress
    //     const token1Address = (
    //         await this.contractDeploymentsJson.readContractDeploymentsJsonFile(
    //             {
    //                 networkName: hre.network.name,
    //                 objectName: 'token1',
    //             },
    //             'readLimitPoolSetup'
    //         )
    //     ).contractAddress
    //     const limitPoolAddress = (
    //         await this.contractDeploymentsJson.readContractDeploymentsJsonFile(
    //             {
    //                 networkName: hre.network.name,
    //                 objectName: 'limitPool',
    //             },
    //             'readLimitPoolSetup'
    //         )
    //     ).contractAddress

    //     const limitPoolFactoryAddress = (
    //         await this.contractDeploymentsJson.readContractDeploymentsJsonFile(
    //             {
    //                 networkName: hre.network.name,
    //                 objectName: 'limitPoolFactory',
    //             },
    //             'readLimitPoolSetup'
    //         )
    //     ).contractAddress

    //     const positionERC1155Address = (
    //         await this.contractDeploymentsJson.readContractDeploymentsJsonFile(
    //             {
    //                 networkName: hre.network.name,
    //                 objectName: 'positionERC1155',
    //             },
    //             'readLimitPoolSetup'
    //         )
    //     ).contractAddress
    //     const poolRouterAddress = (
    //         await this.contractDeploymentsJson.readContractDeploymentsJsonFile(
    //             {
    //                 networkName: hre.network.name,
    //                 objectName: 'poolRouter',
    //             },
    //             'readLimitPoolSetup'
    //         )
    //     ).contractAddress

    //     hre.props.token0 = await hre.ethers.getContractAt('Token20', token0Address)
    //     hre.props.token1 = await hre.ethers.getContractAt('Token20', token1Address)
    //     hre.props.limitPool = await hre.ethers.getContractAt('LimitPool', limitPoolAddress)
    //     hre.props.limitPoolFactory = await hre.ethers.getContractAt('LimitPoolFactory', limitPoolFactoryAddress)
    //     hre.props.limitPoolToken = await hre.ethers.getContractAt('PositionERC1155', positionERC1155Address)
    //     hre.props.poolRouter = await hre.ethers.getContractAt('PoolsharkRouter', poolRouterAddress)

    //     return nonce
    // }
}
