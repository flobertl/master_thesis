## Pkg
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Plots
using HMM_Forecast

## Load Data
hh = 1
include("data.jl");

hmmsSpring(N) = HMM_Forecast.loadHMM("seasonmodel_hh(1)//spring//seasonmodel_states($N)")
hmmsFall(N) = HMM_Forecast.loadHMM("seasonmodel_hh(1)//fall//seasonmodel_states($N)")
hmmsSummer(N) = HMM_Forecast.loadHMM("seasonmodel_hh(1)//summer//seasonmodel_states($N)")
hmmsWinter(N) = HMM_Forecast.loadHMM("seasonmodel_hh(1)//winter//seasonmodel_states($N)")

## Set parameters Spring
trainData = observations[dateIndeces[2,3]:dateIndeces[2,6]-1]
testData =  observations[dateIndeces[3,3]:dateIndeces[3,6]-1]
folderPath = ".//HMM_Forecast//tmp//seasonmodel_hh(1)//spring//seasonmodel_states"


for N in 100:50:200
    hmm = hmmsSpring(N) |> HMM_Forecast.updateHMMNumericalStable
    HMM_Forecast.calcTestingRoutineSeason(hmm, trainData, testData, folderPath*"($N)", "spring")
end

## Set parameters Summer
trainData = observations[dateIndeces[2,6]:dateIndeces[2,9]-1]
testData =  observations[dateIndeces[3,6]:dateIndeces[3,9]-1]
folderPath = ".//HMM_Forecast//tmp//seasonmodel_hh(1)//summer//seasonmodel_states"


for N in 100:50:200
    hmm = hmmsSummer(N) |> HMM_Forecast.updateHMMNumericalStable
    HMM_Forecast.calcTestingRoutineSeason(hmm, trainData, testData, folderPath*"($N)", "Summer")
end

## Set parameters Fall
trainData = observations[dateIndeces[2,9]:dateIndeces[2,12]-1]
testData =  observations[dateIndeces[3,9]:dateIndeces[3,12]-1]
folderPath = ".//HMM_Forecast//tmp//seasonmodel_hh(1)//fall//seasonmodel_states"


for N in 100:50:200
    hmm = hmmsFall(N) |> HMM_Forecast.updateHMMNumericalStable
    HMM_Forecast.calcTestingRoutineSeason(hmm, trainData, testData, folderPath*"($N)", "Fall")
end

## Set parameters winter
trainData = observations[dateIndeces[2,6]:dateIndeces[2,9]-1]
testData =  observations[dateIndeces[3,6]:dateIndeces[3,9]-1]
folderPath = ".//HMM_Forecast//tmp//seasonmodel_hh(1)//winter//seasonmodel_states"


for N in 100:50:200
    hmm = hmmsWinter(N) |> HMM_Forecast.updateHMMNumericalStable
    HMM_Forecast.calcTestingRoutineSeason(hmm, trainData, testData, folderPath*"($N)", "Winter")
end