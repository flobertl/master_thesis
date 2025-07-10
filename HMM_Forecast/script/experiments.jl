using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, ChangePrecision, Plots
using HMM_Forecast

hh = 1
discretTyp = "B"
numberOfObservationsVector =  [50, 100, 200]
numberOfStatesVector = [10, 20, 30, 40, 50, 60]

HMM_Forecast.trainBasisModel(hh, discretTyp, numberOfObservationsVector, numberOfStatesVector)