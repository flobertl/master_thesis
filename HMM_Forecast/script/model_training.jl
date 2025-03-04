# Function to run BasisModel runBasisModelAnalysis
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics, Random, Plots
using HMM_Forecast

# Parameters
hhVector = 1:5
numberOfStatesVector = [1]
numberOfTimeBlocks = [4, 8, 12, 24, 96]

HMM_Forecast.trainAllModels(hhVector, numberOfStatesVector, numberOfTimeBlocks)