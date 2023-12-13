import { SUPPORTED_NETWORKS } from './scripts/constants/supportedNetworks'
import {
    DEPLOY_LIMITPOOL,
    DEPLOY_FINTOKEN,
    INCREASE_SAMPLES,
    MINT_POSITION,
    MINT_TOKENS,
    VERIFY_CONTRACTS,
} from './tasks/constants/taskNames'
import { purpleLog } from './test/utils/colors'

export function handleHardhatTasks() {
    handleLimitPoolTasks()
}

function handleLimitPoolTasks() {
    // for (const network in SUPPORTED_NETWORKS) {
    //     if (Object.keys(LOCAL_NETWORKS).includes(network)) continue;
    //     hre.masterNetwork = MASTER_NETWORKS[network];
    //     break;
    // }
    if (process.argv.includes(DEPLOY_FINTOKEN)) {
        import('./tasks/deploy/deploy-fintoken')
        logTask(DEPLOY_FINTOKEN)
    } else if (process.argv.includes(VERIFY_CONTRACTS)) {
        import('./tasks/deploy/verify-contracts')
        logTask(VERIFY_CONTRACTS)
    }
}

function logTask(taskName: string) {
    purpleLog(`\n🎛  Running ${taskName} task...\n`)
}
