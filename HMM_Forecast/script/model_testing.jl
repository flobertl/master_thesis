# Function to run BasisModel runBasisModelAnalysis
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics, Random, Plots
using HMM_Forecast

# Set Parameters
hhs = 1
numberOfStatesVector =  [1, 5, 10] #vcat(5:5:30,40:10:60)
historicWindowLengthVector = [1, 10, 100, 1000]


#results = HMM_Forecast.evaluateSeasonmodels(numberOfStatesVector, hh)
#results = HMM_Forecast.evaluateSeasonmodelsWithTimeStamps(numberOfTimeBlocks, numberOfStatesVector, hh)
HMM_Forecast.basismodelHyperparameterAnalysis(hhs, numberOfStatesVector, historicWindowLengthVector)