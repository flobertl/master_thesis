# Function to run BasisModel runBasisModelAnalysis
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics, Random, Plots
using HMM_Forecast

# Set Parameters
hh = 2
numberOfStatesVector = 10:10:10
numberOfTimeBlocks = 8


# results = HMM_Forecast.evaluateSeasonmodels(numberOfStatesVector, hh)
results = HMM_Forecast.evaluateSeasonmodelsWithTimeStamps(numberOfTimeBlocks, numberOfStatesVector, hh)
