# Function to run BasisModel runBasisModelAnalysis
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics, Random, Plots
using HMM_Forecast

# Set Parameters
hh = 1
numberOfStatesVector = [50, 300]
numberOfTimeBlocks = 4


#results = HMM_Forecast.evaluateSeasonmodels(numberOfStatesVector, hh)
#results = HMM_Forecast.evaluateSeasonmodelsWithTimeStamps(numberOfTimeBlocks, numberOfStatesVector, hh)
HMM_Forecast.calcPITForBasisModel(numberOfStatesVector, hh)