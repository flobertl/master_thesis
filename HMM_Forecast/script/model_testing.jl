# Function to run BasisModel runBasisModelAnalysis
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics, Random, Plots
using HMM_Forecast

# Set Parameters
hhs = 1
numberOfStatesVector =  [10, 20, 30, 40, 50, 60, 80, 100] #vcat(5:5:30,40:10:60)
historicWindowLengthVector = [5, 10, 20, 50]


#results = HMM_Forecast.evaluateSeasonmodels(numberOfStatesVector, hh)
#results = HMM_Forecast.evaluateSeasonmodelsWithTimeStamps(numberOfTimeBlocks, numberOfStatesVector, hh)
HMM_Forecast.basismodelHyperparameterAnalysis(hhs, numberOfStatesVector, historicWindowLengthVector)

#results = HMM_Forecast.evaluateBasismodel(1, [80, 100])