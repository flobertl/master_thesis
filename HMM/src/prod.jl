# Module For Productive Use
module Prod 

using Main.HMM.Types
using Main.HMM.Data
using Main.HMM.Calc
using Main.HMM.Helpers
using HiddenMarkovModels: HMM as HMMPkg, baum_welch as BWAlgoPkg

export runSingleTraining, runBestPathPrognosis,forwardAlgo, runSingleTrainingPkg

function runSingleTraining(maxIter::Int = 100)
    (observationSpace, observationsAsIndeces) = getTestData2Month()

    # Set Parameter
    N = 10
    initHMM = createRandomHMM(N, observationSpace)

    # Run Algo
    hmm = baumWelchAlgo(initHMM, observationsAsIndeces, )

    # Store Output

    # Return Output
    return hmm
end 

function runSingleTrainingPkg(maxIter::Int = 100)
    (observationSpace, observationsAsIndeces) = getTestData2Month()

    # Set Parameter
    N = 10
    initHMM = createRandomHMM(N, observationSpace)

    # Run House Algo
    hmm1 = baumWelchAlgo(initHMM, observationsAsIndeces, maxIter)

    # Run Pkg Algo
    initHMMPkg = Main.HMM.Helpers.transformHMMToPkgHMM(initHMM)

    hmm2 = BWAlgoPkg(initHMMPkg, observationsAsIndeces, max_iterations = maxIter)

    # Return Output
    return hmm1, hmm2
end 

function runBestPathPrognosis(hmm, forecastHorizon::Int)
    (_, observationsAsIndeces) = getTestDataDay()

    bestPath = bestPathPrognosis(hmm, observationsAsIndeces, forecastHorizon)
end

end