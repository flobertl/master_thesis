## Pkg
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Plots
using HMM_Forecast

## Load Data
hh = 1
include("data.jl");

hmm = HMM_Forecast.loadHMM("seasonmodel_hh(1)//summer//seasonmodel_states(1)")
trainData = observations[dateIndeces[2,6]:dateIndeces[2,9]-1]
testData =  observations[dateIndeces[1,6]:dateIndeces[1,9]-1]
trainDataAsIndeces = observationsAsIndeces[dateIndeces[2,6]:dateIndeces[2,9]-1]
testDataAsIndeces =  observationsAsIndeces[dateIndeces[1,6]:dateIndeces[1,9]-1]



alfa, loglike = HMM_Forecast.forwardAlgo(hmm, testDataAsIndeces)

# Investigate NaN Value
typeof(alfa)
findall(isnan, alfa)
f(x) = (x==4500)
findall(f, trainData)

# Test updateHMMNumericalStable
HMM_Forecast.forwardAlgo(hmm |> HMM_Forecast.updateHMMNumericalStable, testDataAsIndeces)


## Find NAN bug
N = 50
hmm = hmmsSummer(50)
trainData = observations[dateIndeces[2,6]:dateIndeces[2,9]-1]
testData =  observations[dateIndeces[3,6]:dateIndeces[3,9]-1]
folderPath = ".//HMM_Forecast//tmp//seasonmodel_hh(1)//summer//seasonmodel_states"

HMM_Forecast.calcTestingRoutine(hmm, trainData, testData, folderPath*"($N)")

HMM_Forecast.forwardAlgo(hmm, trainData)
