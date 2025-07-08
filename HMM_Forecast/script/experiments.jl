using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, ChangePrecision, Plots
using HMM_Forecast

HMM_Forecast.trainBasisModel(1, "A",2,[1])