include("../src/HMM.jl")

using Main.HMM

x = runSingleTraining();

runBestPathPrognosis(x, 10)

x.transitionMatrix.transitionMatrix