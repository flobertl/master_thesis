include("../src/HMM.jl")

using .HMM.Test

#runUEAll()
#testAll()

hmm, alpha, likelihood = Main.HMM.Test.testBWAlgo()