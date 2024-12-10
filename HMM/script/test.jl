include("../src/HMM.jl")

using .HMM.Test

# runUEAll()
# testAll()

Main.HMM.Test.testBestPathPrognosis()

println(res2[2])