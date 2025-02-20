# Function to run BasisModel runBasisModelAnalysis
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics, Random, Plots
using HMM_Forecast

# Parameters
hh = 2
numberOfStatesVector = 10:10:20
numberOfTimeBlocks = 8
# HMM_Forecast.runBasisModelAnalysis(numberOfStatesVector, 2)

HMM_Forecast.trainSeasonModels(numberOfStatesVector, hh)

#HMM_Forecast.trainSeasonModelsWithTimeStamps(numberOfTimeBlocks, numberOfStatesVector, hh)
