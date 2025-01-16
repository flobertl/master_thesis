include("../src/HMM.jl")

using Distributions, StatsPlots, Plots

x = Main.HMM.Helpers.randomDirichletVector(100)
y = Main.HMM.Helpers.randomDirichletVector(100)

p = plot([1,2], [0.02, 0.03],  legend=false)
violin!(p, [4], [ y], color = :lightcyan2 )
violin!(p, [2], [x],  color = :lightcyan2 )
# 