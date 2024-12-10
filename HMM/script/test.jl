include("../src/HMM.jl")

using .HMM.Test

runUEAll()
testAll()

Main.HMM.Test.testSaveAndLoadHMM()
