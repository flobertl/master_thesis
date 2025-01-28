# Productive functions
using HiddenMarkovModels: HMM as HMMPkg, baum_welch as BWAlgoPkg

export runBWAlgoWithRandomInit, runBestPathPrognosis,forwardAlgo, runSingleTrainingPkg

function runBWAlgoWithRandomInit((observationSpace, observationsAsIndeces), numberStates, maxIter::Int = 100)
    N = numberStates
    initHMM = createRandomHMM(N, observationSpace)
    baumWelchAlgo(initHMM, observationsAsIndeces, maxIter)
end 






