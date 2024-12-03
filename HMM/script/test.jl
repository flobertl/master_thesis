include("../src/HMM.jl")

using .HMM.Test

runUEAll()
testAll()

res1, res2 = Main.HMM.Test.testBWAlgoWithPkg();

println(res2[2])