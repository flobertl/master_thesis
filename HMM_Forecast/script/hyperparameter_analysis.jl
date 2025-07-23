# Function to run BasisModel runBasisModelAnalysis
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics, Random, Plots
using HMM_Forecast

# Parameters
hh = 1
discretTyp = "A"
numberOfObservationsVector =  [10, 25, 50, 100, 200]
numberOfStatesVector = [35, 45, 55] #[10, 20, 30, 40, 50, 60]

# Run Training
HMM_Forecast.trainBasisModel(hh, "A", numberOfObservationsVector, numberOfStatesVector)
HMM_Forecast.trainBasisModel(hh, "B", numberOfObservationsVector, numberOfStatesVector)

# Run evaluation
# HMM_Forecast.hyperparameterAnalysis(hh, discretTyp, numberOfObservationsVector, numberOfStatesVector)
# HMM_Forecast.hyperparameterAnalysis(hh, "B", numberOfObservationsVector, numberOfStatesVector)