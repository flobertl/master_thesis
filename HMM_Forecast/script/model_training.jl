# Function to run BasisModel runBasisModelAnalysis
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics, Random, Plots
using HMM_Forecast

# Parameters
hh = 2
numberOfStatesVector = 70:80
numberOfTimeBlocks = 4

HMM_Forecast.runBasisModelAnalysis(numberOfStatesVector, 2)

#HMM_Forecast.trainSeasonModels(numberOfStatesVector, hh)

~HMM_Forecast.trainSeasonModelsWithTimeStamps(numberOfTimeBlocks, numberOfStatesVector, hh)
