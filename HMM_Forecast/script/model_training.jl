# Function to run BasisModel runBasisModelAnalysis
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics, Random, Plots
using HMM_Forecast

# Parameters
hh = 1
numberOfStatesVector = [80] #vcat(5:5:30,40:10:60)
numberOfTimeBlocks = [4, 8, 12, 24, 96]

HMM_Forecast.trainBasisModels(hh, numberOfStatesVector)