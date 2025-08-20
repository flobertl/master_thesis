# Function to run BasisModel runBasisModelAnalysis
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics, Random, Plots
using HMM_Forecast

# Parameters
# hhs = [5]
hh = 5
numberOfObservationsVector =  [100, 200]
numberOfStatesVector = [10, 20, 30, 40, 50, 60, 70, 80, 100, 120, 150]

for hh in hhs
    # Run Training
    # HMM_Forecast.trainBasisModel(hh, "A", numberOfObservationsVector, numberOfStatesVector)
    # HMM_Forecast.trainBasisModel(hh, "B", numberOfObservationsVector, numberOfStatesVector)

    # Run evaluation
    # HMM_Forecast.hyperparameterAnalysis(hh, "A", numberOfObservationsVector, numberOfStatesVector)
    # HMM_Forecast.hyperparameterAnalysis(hh, "B", numberOfObservationsVector, numberOfStatesVector)

    # # Plot results
    # HMM_Forecast.plotHyperparameterAnalysis(hh, "A")
    # HMM_Forecast.plotHyperparameterAnalysis(hh, "B")
end


