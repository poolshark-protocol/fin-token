import { task } from 'hardhat/config'
import { GetBeforeEach } from '../../test/utils/setup/beforeEachProps'
import { DEPLOY_FINTOKEN } from '../constants/taskNames'
import { DeployFinToken } from './utils/deployFinToken'

class DeployFinTokenTask {
    public DeployFinToken: DeployFinToken
    public getBeforeEach: GetBeforeEach

    constructor() {
        this.DeployFinToken = new DeployFinToken()
        this.getBeforeEach = new GetBeforeEach()
        hre.props = this.getBeforeEach.retrieveProps()
    }
}

task(DEPLOY_FINTOKEN)
    .setDescription('Deploys Cover Pools')
    .setAction(async function ({ ethers }) {
        const DeployFinToken: DeployFinTokenTask = new DeployFinTokenTask()

        if (!DeployFinToken.DeployFinToken.canDeploy()) return

        await DeployFinToken.DeployFinToken.preDeployment()

        await DeployFinToken.DeployFinToken.runDeployment()

        await DeployFinToken.DeployFinToken.postDeployment()

        console.log('FIN token deployment complete.\n')
    })
