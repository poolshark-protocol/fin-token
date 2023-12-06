import { task } from 'hardhat/config'
import { GetBeforeEach } from '../../test/utils/setup/beforeEachProps'
import { INCREASE_SAMPLES } from '../constants/taskNames'
import { IncreaseSamples } from '../deploy/utils/increaseSamples'

class IncreaseSamplesTask {
    public DeployFinToken: IncreaseSamples
    public getBeforeEach: GetBeforeEach

    constructor() {
        this.DeployFinToken = new IncreaseSamples()
        this.getBeforeEach = new GetBeforeEach()
        hre.props = this.getBeforeEach.retrieveProps()
    }
}

task(INCREASE_SAMPLES)
    .setDescription('Increase Twap Sample Length on Mock Pool')
    .setAction(async function ({ ethers }) {
        const DeployFinToken: IncreaseSamplesTask = new IncreaseSamplesTask()

        if (!DeployFinToken.DeployFinToken.canDeploy()) return

        await DeployFinToken.DeployFinToken.preDeployment()

        await DeployFinToken.DeployFinToken.runDeployment()

        await DeployFinToken.DeployFinToken.postDeployment()

        console.log('Cover pool deployment complete.\n')
    })
