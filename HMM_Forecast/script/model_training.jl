# Function to run BasisModel runBasisModelAnalysis
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics, Random, Plots
using HMM_Forecast

# Parameters
hh = 2
numberOfStatesVector = [80, 100] #vcat(5:5:30,40:10:60)
numberOfTimeBlocks = [4, 8, 12, 24, 96]

HMM_Forecast.trainBasisModels(2, numberOfStatesVector)
HMM_Forecast.trainBasisModels(3, numberOfStatesVector)