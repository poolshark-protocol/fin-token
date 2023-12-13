import { SUPPORTED_NETWORKS } from '../../../scripts/constants/supportedNetworks'
import { DeployAssist } from '../../../scripts/util/deployAssist'
import { ContractDeploymentsKeys } from '../../../scripts/util/files/contractDeploymentKeys'
import { ContractDeploymentsJson } from '../../../scripts/util/files/contractDeploymentsJson'
import { FIN__factory } from '../../../typechain'

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

    private owner = {
        'hardhat': '0xBd5db4c7D55C086107f4e9D17c4c34395D1B1E1E',
        'scrollSepolia': '0xBd5db4c7D55C086107f4e9D17c4c34395D1B1E1E',
        'arb_goerli': '0xBd5db4c7D55C086107f4e9D17c4c34395D1B1E1E',
        'arb_one': '0xf37A475c178dfbEC96088FA7904a861336002c6a',
    }

    constructor() {
        this.deployAssist = new DeployAssist()
        this.contractDeploymentsJson = new ContractDeploymentsJson()
        this.contractDeploymentsKeys = new ContractDeploymentsKeys()
        this.constantProductString = ethers.utils.formatBytes32String('CONSTANT-PRODUCT')
    }

    public async initialFinTokenSetup(): Promise<number> {
        const network = SUPPORTED_NETWORKS[hre.network.name.toUpperCase()]

        this.owner['hardhat']
        
        if (this.deployTokens || hre.network.name == 'hardhat') {
            console.log('deploy token', hre.network.name)
            await this.deployAssist.deployContractWithRetry(
                network,
                //@ts-ignore
                FIN__factory,
                'finToken',
                [
                    this.owner[hre.network.name]
                ]
            )
        }

        return hre.nonce
    }

    public async readLimitPoolSetup(nonce: number): Promise<number> {
        const token0Address = (
            await this.contractDeploymentsJson.readContractDeploymentsJsonFile(
                {
                    networkName: hre.network.name,
                    objectName: 'token0',
                },
                'readLimitPoolSetup'
            )
        ).contractAddress
        const token1Address = (
            await this.contractDeploymentsJson.readContractDeploymentsJsonFile(
                {
                    networkName: hre.network.name,
                    objectName: 'token1',
                },
                'readLimitPoolSetup'
            )
        ).contractAddress
        const limitPoolAddress = (
            await this.contractDeploymentsJson.readContractDeploymentsJsonFile(
                {
                    networkName: hre.network.name,
                    objectName: 'limitPool',
                },
                'readLimitPoolSetup'
            )
        ).contractAddress

        const limitPoolFactoryAddress = (
            await this.contractDeploymentsJson.readContractDeploymentsJsonFile(
                {
                    networkName: hre.network.name,
                    objectName: 'limitPoolFactory',
                },
                'readLimitPoolSetup'
            )
        ).contractAddress

        const positionERC1155Address = (
            await this.contractDeploymentsJson.readContractDeploymentsJsonFile(
                {
                    networkName: hre.network.name,
                    objectName: 'positionERC1155',
                },
                'readLimitPoolSetup'
            )
        ).contractAddress
        const poolRouterAddress = (
            await this.contractDeploymentsJson.readContractDeploymentsJsonFile(
                {
                    networkName: hre.network.name,
                    objectName: 'poolRouter',
                },
                'readLimitPoolSetup'
            )
        ).contractAddress

        hre.props.token0 = await hre.ethers.getContractAt('Token20', token0Address)
        hre.props.token1 = await hre.ethers.getContractAt('Token20', token1Address)
        hre.props.limitPool = await hre.ethers.getContractAt('LimitPool', limitPoolAddress)
        hre.props.limitPoolFactory = await hre.ethers.getContractAt('LimitPoolFactory', limitPoolFactoryAddress)
        hre.props.limitPoolToken = await hre.ethers.getContractAt('PositionERC1155', positionERC1155Address)
        hre.props.poolRouter = await hre.ethers.getContractAt('PoolsharkRouter', poolRouterAddress)

        return nonce
    }

    public async createLimitPool(): Promise<void> {
        // await hre.props.limitPoolFactory
        //   .connect(hre.props.admin)
        //   .createLimitPool({
        //     poolType: this.constantProductString,
        //     tokenIn: hre.props.token0.address,
        //     tokenOut: hre.props.token1.address,
        //     swapFee: '10000',
        //     startPrice: '177159557114295710296101716160'
        //   })
        // hre.nonce += 1
        // 1000
        // 3000
        // 10000
        let poolTxn = await hre.props.limitPoolFactory
          .connect(hre.props.admin)
          .createLimitPool({
            poolTypeId: 0,
            tokenIn: '0x5339F8fDFc2a9bE081fc1d924d9CF1473dA46C68',  // stETH
            tokenOut: '0x3a56859B3E176636095c142c87F73cC57B408b67', // USDC
            swapFee: '1000',
            startPrice: '3169126500570573503741758013440'
        })
        await poolTxn.wait()
        hre.nonce += 1
        poolTxn = await hre.props.limitPoolFactory
            .connect(hre.props.admin)
            .createLimitPool({
            poolTypeId: 0,
            tokenIn: '0x681cfAC3f265b6041FF4648A1CcB214F1c0DcF38',  // YFI
            tokenOut: '0x7dCF144D7f39d7aD7aE0E6F9E612379F73BD8E80', // DAI
            swapFee: '1000',
            startPrice: '177159557114295710296101716160'
        })
        await poolTxn.wait()
        hre.nonce += 1
        poolTxn = await hre.props.limitPoolFactory
        .connect(hre.props.admin)
        .createLimitPool({
            poolTypeId: 0,
            tokenIn: '0x681cfAC3f265b6041FF4648A1CcB214F1c0DcF38',  // YFI
            tokenOut: '0xa9e1ab5e6878621F80E03A4a5F8FB3705F4FFA2B', // SUSHI
            swapFee: '1000',
            startPrice: '177159557114295710296101716160'
        })
        await poolTxn.wait()
        hre.nonce += 1
        poolTxn = await hre.props.limitPoolFactory
        .connect(hre.props.admin)
        .createLimitPool({
            poolTypeId: 0,
            tokenIn: '0x3a56859B3E176636095c142c87F73cC57B408b67',  // USDC
            tokenOut: '0x7dCF144D7f39d7aD7aE0E6F9E612379F73BD8E80', // DAI
            swapFee: '1000',
            startPrice: '177159557114295710296101716160'
        })
        await poolTxn.wait()
        hre.nonce += 1
    }
}
