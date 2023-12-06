import { task } from 'hardhat/config'
import { GetBeforeEach } from '../../test/utils/setup/beforeEachProps'
import { DEPLOY_FINTOKEN, VERIFY_CONTRACTS } from '../constants/taskNames'
import { VerifyContracts } from './utils/verifyContracts'

class VerifyContractsTask {
    public DeployFinToken: VerifyContracts
    public getBeforeEach: GetBeforeEach

    constructor() {
        this.DeployFinToken = new VerifyContracts()
        this.getBeforeEach = new GetBeforeEach()
        hre.props = this.getBeforeEach.retrieveProps()
    }
}

task(VERIFY_CONTRACTS)
    .setDescription('Verifies all contracts')
    .setAction(async function ({ ethers }) {
        const DeployFinToken: VerifyContractsTask = new VerifyContractsTask()

        if (!DeployFinToken.DeployFinToken.canDeploy()) return

        await DeployFinToken.DeployFinToken.preDeployment()

        await DeployFinToken.DeployFinToken.runDeployment()

        await DeployFinToken.DeployFinToken.postDeployment()

        console.log('Contract verification complete.\n')
    })
