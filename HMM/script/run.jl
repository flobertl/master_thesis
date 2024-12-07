include("../src/HMM.jl")

using Main.HMM

hmm1, hmm2 = runSingleTrainingPkg(10);

transMatrix1 = hmm1[1][1].transitionMatrix.transitionMatrix
transMatrix2 = hmm1[2][1].trans



# runBestPathPrognosis(x, 10)

# x.transitionMatrix.transitionMatrix