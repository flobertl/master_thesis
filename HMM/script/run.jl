include("../src/HMM.jl")

using Main.HMM

hmm1, hmm2 = runSingleTrainingPkg();


hmm2[2]
# runBestPathPrognosis(x, 10)

# x.transitionMatrix.transitionMatrix