using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, ChangePrecision
using HMM_Forecast

(observationSpace, observations, observationsAsIndeces) = HMM_Forecast.getData2Years_Seasonstamps(1)
dates = HMM_Forecast.dateTimesOf2YearsData()
HMM_Forecast.addSeasonstamps(observations, dates)[1]

observations[1]