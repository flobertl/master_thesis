# Module For Productive Use
module Prod 

using Main.HMM.Types
using Main.HMM.Data
using Main.HMM.Calc
using Main.HMM.Helpers, Main.HMM.Plot
using HiddenMarkovModels: HMM as HMMPkg, baum_welch as BWAlgoPkg

export runBWAlgoWithRandomInit, runSingleTraining, runBestPathPrognosis,forwardAlgo, runSingleTrainingPkg, plots

function runSingleTraining(maxIter::Int = 100)
    (observationSpace, observationsAsIndeces) = getTestDataDay()

    # Set Parameter
    N = 10
    initHMM = createRandomHMM(N, observationSpace)

    # Run Algo
    hmm = baumWelchAlgo(initHMM, observationsAsIndeces, maxIter)

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
    #hmm1 = baumWelchAlgo(initHMM, observationsAsIndeces, maxIter)

    # Run Pkg Algo
    initHMMPkg = Main.HMM.Helpers.transformHMMToPkgHMM(initHMM)

    hmm2 = BWAlgoPkg(initHMMPkg, observationsAsIndeces, max_iterations = maxIter)

    # Return Output
    return hmm1, hmm2
end 

function runBWAlgoWithRandomInit((observationSpace, observationsAsIndeces), numberStates, maxIter::Int = 100)
    N = numberStates
    initHMM = createRandomHMM(N, observationSpace)
    baumWelchAlgo(initHMM, observationsAsIndeces, maxIter)
end 

function runBWAlgoWithGivenInit(observationsAsIndeces, initHMM, maxIter::Int = 100)
    baumWelchAlgo(initHMM, observationsAsIndeces, maxIter)
end 

function runBestPathPrognosis(hmm, forecastHorizon::Int)
    (_, observationsAsIndeces) = getTestDataDay()

    bestPath = bestPathPrognosis(hmm, observationsAsIndeces, forecastHorizon)
end

function plots()
    # Load Data
    (observationSpace, observationsAsIndeces) = getTestData2Month()
    observations = translateIndexToObservations(observationsAsIndeces, observationSpace)

    p1 = plotHist(observations);

    # Set Parameter
    N = 100
    initHMM = createRandomHMM(N, observationSpace)
    # Run House Algo
    hmm1, alpha, likelihood = baumWelchAlgo(initHMM, observationsAsIndeces, 30)
    forecastAsIndeces, likelihood = bestPathPrognosis(hmm1, observationsAsIndeces, 50)
    forecast = translateIndexToObservations(forecastAsIndeces, observationSpace)

    p2 = plotForecast(observations, forecast)
    p1, p2
end

function runTrainingAndStoreHMM((observationSpace, observationsAsIndeces), numberStates, maxIter::Int = 100)

end

end