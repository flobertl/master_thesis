# Function to run BasisModel runBasisModelAnalysis
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics, Random, Plots
using HMM_Forecast

# Set Parameters
hhs = 1:5
numberOfStatesVector =  40:10:60 #vcat(5:5:30,40:10:60)
numberOfTimeBlocks = [4, 8, 12, 24, 96]


#results = HMM_Forecast.evaluateSeasonmodels(numberOfStatesVector, hh)
#results = HMM_Forecast.evaluateSeasonmodelsWithTimeStamps(numberOfTimeBlocks, numberOfStatesVector, hh)
HMM_Forecast.evaluateAllModels(hhs, numberOfStatesVector, numberOfTimeBlocks)