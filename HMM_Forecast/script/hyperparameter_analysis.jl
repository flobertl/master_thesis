# Function to run BasisModel runBasisModelAnalysis
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics, Random, Plots
using HMM_Forecast

# Parameterslk
hhs = [ 4, 5]
numberOfObservationsVector =  [25, 50, 100, 200]
numberOfStatesVector = [10, 20, 30, 40, 50, 60, 70, 80]

for hh in hhs
    # Run Training
    HMM_Forecast.trainBasisModel(hh, "A", numberOfObservationsVector, numberOfStatesVector)
    HMM_Forecast.trainBasisModel(hh, "B", numberOfObservationsVector, numberOfStatesVector)
end
# # Run evaluation
# HMM_Forecast.hyperparameterAnalysis(hh, "A", numberOfObservationsVector, numberOfStatesVector)
# HMM_Forecast.hyperparameterAnalysis(hh, "A", numberOfObservationsVector, numberOfStatesVector)

# # Plot results
#HMM_Forecast.plotHyperparameterAnalysis(hh, "A")