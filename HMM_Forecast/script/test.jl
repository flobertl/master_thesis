using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, ChangePrecision
using HMM_Forecast

#runUEAll()
#HMM_Forecast.testAll()

HMM_Forecast.testLoadAndNormalizeData()
