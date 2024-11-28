include("../src/HMM.jl")

using Main.HMM

x, a = runSingleTraining();

runBestPathPrognosis(x, 10)

x.transitionMatrix.transitionMatrix