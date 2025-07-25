# Function to run BasisModel runBasisModelAnalysis
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics, Random, Plots
using HMM_Forecast

# Parameters
hh = 1
numberOfObservationsVector =  [25, 50, 100, 200]
numberOfStatesVector = [10, 20, 30, 35, 40, 45, 50, 55, 60]

# Run Training
# HMM_Forecast.trainBasisModel(hh, "A", numberOfObservationsVector, numberOfStatesVector)
# HMM_Forecast.trainBasisModel(hh, "B", numberOfObservationsVector, numberOfStatesVector)

# Run evaluation
HMM_Forecast.hyperparameterAnalysis(hh, "B", numberOfObservationsVector, numberOfStatesVector)
HMM_Forecast.hyperparameterAnalysis(hh, "B", numberOfObservationsVector, numberOfStatesVector)

# Plot results
# HMM_Forecast.plotHyperparameterAnalysis(hh, "B")