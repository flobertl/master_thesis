## Pkg
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, ChangePrecision, Dates, Plots
using HMM_Forecast

hh = 1
include("data.jl");
trainData = trainDataSummer
testData = testDataSummer


forecast = HMM_Forecast.generateBaselineForecast(observationSpace, trainData, length(testData))

## Evaluate models
(mape, r_sqare, crps) = HMM_Forecast.calcEvaluationGivenForecast(observationSpace, testData, forecast)
HMM_Forecast.printEvaluation("Baseline model Summer", ((0,0), mape, r_sqare, crps))

## Naives model
naivePred = HMM_Forecast.naivePrediction(trainData, testData)
HMM_Forecast.evalPointForecast(testData, naivePred)


# Calc Distribution Forecast
x = 2000
H = 50
T = 20
hmm = hmmSummer(50)

testDataFallAsIndeces = HMM_Forecast.translateObservationsToIndex(testDataSummer, hmm.observationSpace)
forecast = HMM_Forecast.forecastDistribution(hmm |> HMM_Forecast.updateHMMNumericalStable, testDataFallAsIndeces[1:x-H], H)
testDataFallAsIndeces[x-H-T+1:x-H]
testDataFallAsIndeces[x-H+1:x]
forecast[1:end]

p = HMM_Forecast.plotDistributionForecastWithViolin(hmm, testDataSummer[x-H-T+1:x-H], testDataSummer[x-H+1:x], forecast[1:end])
