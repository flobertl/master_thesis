## Pkg
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, ChangePrecision, Dates, Plots
using HMM_Forecast

hh = 1
include("data_timestamp.jl");

hmmFall(N) = HMM_Forecast.loadHMM("seasonmodel_timestamps_hh($hh)//fall//seasonmodel_states($N)")
hmmSpring(N) = HMM_Forecast.loadHMM("seasonmodel_timestamps_hh($hh)//spring//seasonmodel_states($N)")
hmmSummer(N) = HMM_Forecast.loadHMM("seasonmodel_timestamps_hh($hh)//summer//seasonmodel_states($N)")
hmmWinter(N) = HMM_Forecast.loadHMM("seasonmodel_timestamps_hh($hh)//winter//seasonmodel_states($N)")


## Evaluate models Summer
season = "Summer"
results= Dict()
for (hmm, N) in [(hmmSummer(100), 100)]
    evalResult = HMM_Forecast.calcEvaluation(hmm, trainDataSummer, testDataSummer)
    HMM_Forecast.printEvaluation("Season Model Summer states($N)", evalResult)
end

# Calc Distribution Forecast
x = 1000
H = 100
T = 20
hmm = hmmFall(100)

testDataFallAsIndeces = HMM_Forecast.translateObservationsToIndex(testDataFall, hmm.observationSpace)
forecast = HMM_Forecast.forecastDistribution(hmm |> HMM_Forecast.updateHMMNumericalStable, testDataFallAsIndeces[1:x-H], H)
testDataFallAsIndeces[x-H-T+1:x-H]
testDataFallAsIndeces[x-H+1:x]
forecast[1:end]

p = HMM_Forecast.plotDistributionForecastWithViolin(hmm, testDataFall[x-H-T+1:x-H], testDataFall[x-H+1:x], forecast[1:end])



## Set Parameters
# hh = 1
# iter = 100
# states = [100, 200]
# timeBlocks = 8 
# (observationSpace, observations, observationsAsIndeces) = HMM_Forecast.getData2Years_Timestamps(hh, timeBlocks);
# dates = HMM_Forecast.dateTimesOf2YearsData()
# dateIndeces = HMM_Forecast.calcFirstQHofYearAndMonth()

# for state in states
#     N = state
#     filePath = "seasonmodel_timestamps_hh($hh)//fall//seasonmodel_states($N)"
#     filePath = "seasonmodel_timestamps_hh($hh)//fall//seasonmodel_states($N)"

#     dataTraining = observations[dateIndeces[2, 9] : (dateIndeces[2, 12] - 1)]
#     dataTests = observations[dateIndeces[3, 9] : (dateIndeces[3, 12] - 1)]
#     dataTrainingAsIndeces = observationsAsIndeces[dateIndeces[2, 9] : (dateIndeces[2, 12] - 1)]
#     dataTestAsIndeces = observationsAsIndeces[dateIndeces[3, 9] : (dateIndeces[3, 12] - 1)]

#     ## Train HMM and save and data
#     prevTime = now()
#     println("\n ########################### MODEL $N states #################################")
#     println("-------------- Train Model with $N states------------------")
#     hmm, logliklihood_hmm = HMM_Forecast.runBWAlgoWithRandomInit((observationSpace, dataTrainingAsIndeces), N, iter);
#     HMM_Forecast.saveHMM(hmm, filePath)
#     HMM_Forecast.saveHMM(hmm, filePath)
#     prevTime = HMM_Forecast.printTimeAndResetTimeStamp(prevTime)

#     ## Generate Distro forecast
#     println("-------------- Calc forecast distribution for {$N} states------------------")
#     distributionForecastVector = HMM_Forecast.createSeveralOneStepPredictions(hmm |> HMM_Forecast.updateHMMNumericalStable, dataTrainingAsIndeces, dataTestAsIndeces)::Vector{Vector{Float64}};
#     distributionForecastVector = HMM_Forecast.createSeveralOneStepPredictions(hmm |> HMM_Forecast.updateHMMNumericalStable, dataTrainingAsIndeces, dataTestAsIndeces)::Vector{Vector{Float64}};
#     prevTime = HMM_Forecast.printTimeAndResetTimeStamp(prevTime)

#     println("-------------- Generate PIT plots for {$N} states------------------")
#     pitFall = HMM_Forecast.plotPIT(hmm, dataTests, distributionForecastVector, "Fall")
#     pit0300 = HMM_Forecast.plotPIT(hmm, dataTests[1+3*4:96:end], distributionForecastVector[1+3*4:96:end], "03:00")
#     pit0900 = HMM_Forecast.plotPIT(hmm, dataTests[1+9*4:96:end], distributionForecastVector[1+9*4:96:end], "09:00")
#     pit01500 = HMM_Forecast.plotPIT(hmm, dataTests[1+15*4:96:end], distributionForecastVector[1+15*4:96:end], "15:00")
#     pit2100 = HMM_Forecast.plotPIT(hmm, dataTests[1+21*4:96:end], distributionForecastVector[1+21*4:96:end], "21:00")
#     pitSpecificTimes = plot(pit0300, pit0900, pit01500, pit2100, layout=(2,2))
#     png(pitSpecificTimes, ".//HMM_Forecast//tmp//"*filePath*"_pitSpecificTimes.png")
#     png(pitFall, ".//HMM_Forecast//tmp//"*filePath*"_pitSeason.png")
#     png(pitSpecificTimes, ".//HMM_Forecast//tmp//"*filePath*"_pitSpecificTimes.png")
#     png(pitFall, ".//HMM_Forecast//tmp//"*filePath*"_pitSeason.png")
#     prevTime = HMM_Forecast.printTimeAndResetTimeStamp(prevTime)
# end

# for state in collect(states)
#     N = state
#     filePath = "seasonmodel_timestamps_hh($hh)//winter//seasonmodel_states($N)"

#     dataTraining = observations[dateIndeces[1, 12] : (dateIndeces[2, 3] - 1)]
#     dataTests = observations[dateIndeces[2, 12] : (dateIndeces[3, 3] - 1)]
#     dataTrainingAsIndeces = observationsAsIndeces[dateIndeces[1, 12] : (dateIndeces[2, 3] - 1)]
#     dataTestAsIndeces = observationsAsIndeces[dateIndeces[2, 12] : (dateIndeces[3, 3] - 1)]

#     ## Train HMM and save and data
#     prevTime = now()
#     println("\n ########################### MODEL $N states #################################")
#     println("-------------- Train Model with $N states------------------")
#     hmm, logliklihood_hmm = HMM_Forecast.runBWAlgoWithRandomInit((observationSpace, dataTrainingAsIndeces), N, iter);
#     HMM_Forecast.saveHMM(hmm, filePath)
#     HMM_Forecast.saveHMM(hmm, filePath)
#     prevTime = HMM_Forecast.printTimeAndResetTimeStamp(prevTime)

#     ## Generate Distro forecast
#     println("-------------- Calc forecast distribution for {$N} states------------------")
#     distributionForecastVector = HMM_Forecast.createSeveralOneStepPredictions(hmm |> HMM_Forecast.updateHMMNumericalStable, dataTrainingAsIndeces, dataTestAsIndeces)::Vector{Vector{Float64}};
#     distributionForecastVector = HMM_Forecast.createSeveralOneStepPredictions(hmm |> HMM_Forecast.updateHMMNumericalStable, dataTrainingAsIndeces, dataTestAsIndeces)::Vector{Vector{Float64}};
#     prevTime = HMM_Forecast.printTimeAndResetTimeStamp(prevTime)

#     println("-------------- Generate PIT plots for {$N} states------------------")
#     pitFall = HMM_Forecast.plotPIT(hmm, dataTests, distributionForecastVector, "winter")
#     pit0300 = HMM_Forecast.plotPIT(hmm, dataTests[1+3*4:96:end], distributionForecastVector[1+3*4:96:end], "03:00")
#     pit0900 = HMM_Forecast.plotPIT(hmm, dataTests[1+9*4:96:end], distributionForecastVector[1+9*4:96:end], "09:00")
#     pit01500 = HMM_Forecast.plotPIT(hmm, dataTests[1+15*4:96:end], distributionForecastVector[1+15*4:96:end], "15:00")
#     pit2100 = HMM_Forecast.plotPIT(hmm, dataTests[1+21*4:96:end], distributionForecastVector[1+21*4:96:end], "21:00")
#     pitSpecificTimes = plot(pit0300, pit0900, pit01500, pit2100, layout=(2,2))
#     png(pitSpecificTimes, ".//HMM_Forecast//tmp//"*filePath*"_pitSpecificTimes.png")
#     png(pitFall, ".//HMM_Forecast//tmp//"*filePath*"_pitSeason.png")
#     png(pitSpecificTimes, ".//HMM_Forecast//tmp//"*filePath*"_pitSpecificTimes.png")
#     png(pitFall, ".//HMM_Forecast//tmp//"*filePath*"_pitSeason.png")
#     prevTime = HMM_Forecast.printTimeAndResetTimeStamp(prevTime)
# end