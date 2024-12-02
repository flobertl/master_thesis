# Module For Productive Use
module Prod 

using Main.HMM.Types
using Main.HMM.Data
using Main.HMM.Calc
using Main.HMM.Helpers

export runSingleTraining, runBestPathPrognosis,forwardAlgo

function runSingleTraining()
    (observationSpace, observationsAsIndeces) = getTestDataDay()

    # Set Parameter
    N = 10
    initHMM = createRandomHMM(N, observationSpace)

    # Run Algo
    hmm = baumWelchAlgo(initHMM, observationsAsIndeces)

    # Store Output

    # Return Output
    return hmm
end 

function runBestPathPrognosis(hmm, forecastHorizon::Int)
    (_, observationsAsIndeces) = getTestDataDay()

    bestPath = bestPathPrognosis(hmm, observationsAsIndeces, forecastHorizon)
end

end