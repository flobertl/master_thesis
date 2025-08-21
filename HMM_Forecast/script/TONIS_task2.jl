# Task 2 fuer TONIs Maschine
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics, Random, Plots
using HMM_Forecast

# Parameters
hhs = [1, 2, 3, 4]
numberOfObservationsVector =  [100, 200]
numberOfStatesVector = [120, 150, 200]

for hh in hhs
    # Run Training
    HMM_Forecast.trainBasisModel(hh, "A", numberOfObservationsVector, numberOfStatesVector)
    HMM_Forecast.trainBasisModel(hh, "B", numberOfObservationsVector, numberOfStatesVector)

    # Run evaluation
    HMM_Forecast.hyperparameterAnalysis(hh, "A", numberOfObservationsVector, numberOfStatesVector)
    HMM_Forecast.hyperparameterAnalysis(hh, "B", numberOfObservationsVector, numberOfStatesVector)
end
println("\n \n  ----------- FINISH ------------------ ")