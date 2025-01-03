include("../src/HMM.jl")

using Main.HMM

p1, p2 = runSingleTraining(1000)

p1
p2
# runBestPathPrognosis(x, 10)

# x.transitionMatrix.transitionMatrix