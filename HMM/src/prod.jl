# Module For Productive Use
module Prod 

using Main.HMM.Types
using Main.HMM.Data
using Main.HMM.Calc
using Main.HMM.Helpers

export runSingleTraining, runBestPathPrognosis,forwardAlgo

function runSingleTraining()
    # Set Parameter
    N = 10

    (observationSpace, observationsAsIndeces) = getTestDataDay()

    # Run Algo
    hmm = baumWelchAlgo(observationsAsIndeces, observationSpace, N)

    # Store Output

    # Return Output
    return hmm
end 

function runBestPathPrognosis(hmm, forecastHorizon::Int)
    (_, observationsAsIndeces) = getTestDataDay()

    bestPath = bestPathPrognosis(hmm, observationsAsIndeces, forecastHorizon)
end

end