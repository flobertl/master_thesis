## Pkg
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, ChangePrecision, Dates, Plots
using HMM_Forecast

## Set Parameters
hh = 1
iter = 100
states = [50]
timeBlocks = 8 
(observationSpace, observations, observationsAsIndeces) = HMM_Forecast.getData2Years_Timestamps(hh, timeBlocks);
dates = HMM_Forecast.dateTimesOf2YearsData()
dateIndeces = HMM_Forecast.calcFirstQHofYearAndMonth()

## Spring
for state in states
    N = state
    filePath = "seasonmodel_timestamps_hh($hh)//spring//seasonmodel_states($N)"

    dataTraining = observations[dateIndeces[2, 3] : (dateIndeces[2, 6] - 1)]
    dataTests = observations[dateIndeces[3, 3] : (dateIndeces[3, 6] - 1)]
    dataTrainingAsIndeces = observationsAsIndeces[dateIndeces[2, 3] : (dateIndeces[2, 6] - 1)]
    dataTestAsIndeces = observationsAsIndeces[dateIndeces[3, 3] : (dateIndeces[3, 6] - 1)]

    ## Train HMM and save and data
    prevTime = now()
    println("\n ########################### MODEL $N states #################################")
    println("-------------- Train Model with $N states------------------")
    hmm, logliklihood_hmm = HMM_Forecast.runBWAlgoWithRandomInit((observationSpace, dataTrainingAsIndeces), N, iter);
    HMM_Forecast.saveHMM(hmm, filePath)
    prevTime = HMM_Forecast.printTimeAndResetTimeStamp(prevTime)

    ## Generate Distro forecast
    println("-------------- Calc forecast distribution for {$N} states------------------")
    distributionForecastVector = HMM_Forecast.createSeveralOneStepPredictions(hmm |> HMM_Forecast.updateHMMNumericalStable, dataTrainingAsIndeces, dataTestAsIndeces)::Vector{Vector{Float64}};
    prevTime = HMM_Forecast.printTimeAndResetTimeStamp(prevTime)

    println("-------------- Generate PIT plots for {$N} states------------------")
    pitFall = HMM_Forecast.plotPIT(hmm, dataTests, distributionForecastVector, "spring")
    pit0300 = HMM_Forecast.plotPIT(hmm, dataTests[1+3*4:96:end], distributionForecastVector[1+3*4:96:end], "03:00")
    pit0900 = HMM_Forecast.plotPIT(hmm, dataTests[1+9*4:96:end], distributionForecastVector[1+9*4:96:end], "09:00")
    pit01500 = HMM_Forecast.plotPIT(hmm, dataTests[1+15*4:96:end], distributionForecastVector[1+15*4:96:end], "15:00")
    pit2100 = HMM_Forecast.plotPIT(hmm, dataTests[1+21*4:96:end], distributionForecastVector[1+21*4:96:end], "21:00")
    pitSpecificTimes = plot(pit0300, pit0900, pit01500, pit2100, layout=(2,2))
    png(pitSpecificTimes, ".//HMM_Forecast//tmp//"*filePath*"_pitSpecificTimes.png")
    png(pitFall, ".//HMM_Forecast//tmp//"*filePath*"_pitSeason.png")
    prevTime = HMM_Forecast.printTimeAndResetTimeStamp(prevTime)
end

## summer
for state in states
    N = state
    filePath = "seasonmodel_hh($hh)//summer//seasonmodel_states($N)"

    dataTraining = observations[dateIndeces[2, 6] : (dateIndeces[2, 9] - 1)]
    dataTests = observations[dateIndeces[3, 6] : (dateIndeces[3, 9] - 1)]
    dataTrainingAsIndeces = observationsAsIndeces[dateIndeces[2, 6] : (dateIndeces[2, 9] - 1)]
    dataTestAsIndeces = observationsAsIndeces[dateIndeces[3, 6] : (dateIndeces[3, 9] - 1)]

    ## Train HMM and save and data
    prevTime = now()
    println("\n ########################### MODEL $N states #################################")
    println("-------------- Train Model with $N states------------------")
    hmm, logliklihood_hmm = HMM_Forecast.runBWAlgoWithRandomInit((observationSpace, dataTrainingAsIndeces), N, iter);
    HMM_Forecast.saveHMM(hmm, filePath)
    prevTime = HMM_Forecast.printTimeAndResetTimeStamp(prevTime)

    ## Generate Distro forecast
    println("-------------- Calc forecast distribution for {$N} states------------------")
    distributionForecastVector = HMM_Forecast.createSeveralOneStepPredictions(hmm |> HMM_Forecast.updateHMMNumericalStable, dataTrainingAsIndeces, dataTestAsIndeces)::Vector{Vector{Float64}};
    prevTime = HMM_Forecast.printTimeAndResetTimeStamp(prevTime)

    println("-------------- Generate PIT plots for {$N} states------------------")
    pitFall = HMM_Forecast.plotPIT(hmm, dataTests, distributionForecastVector, "summer")
    pit0300 = HMM_Forecast.plotPIT(hmm, dataTests[1+3*4:96:end], distributionForecastVector[1+3*4:96:end], "03:00")
    pit0900 = HMM_Forecast.plotPIT(hmm, dataTests[1+9*4:96:end], distributionForecastVector[1+9*4:96:end], "09:00")
    pit01500 = HMM_Forecast.plotPIT(hmm, dataTests[1+15*4:96:end], distributionForecastVector[1+15*4:96:end], "15:00")
    pit2100 = HMM_Forecast.plotPIT(hmm, dataTests[1+21*4:96:end], distributionForecastVector[1+21*4:96:end], "21:00")
    pitSpecificTimes = plot(pit0300, pit0900, pit01500, pit2100, layout=(2,2))
    png(pitSpecificTimes, ".//HMM_Forecast//tmp//"*filePath*"_pitSpecificTimes.png")
    png(pitFall, ".//HMM_Forecast//tmp//"*filePath*"_pitSeason.png")
    prevTime = HMM_Forecast.printTimeAndResetTimeStamp(prevTime)
end
