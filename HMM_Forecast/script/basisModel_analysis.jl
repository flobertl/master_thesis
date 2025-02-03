## Pkg
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, ChangePrecision, Dates, Plots
using HMM_Forecast

## Set Parameters
hh = 1
N = 50


# Run Training
# @changeprecision Float32 begin
# # Load data and model
#     hh = 1
#     states = [N]

#     HMM_Forecast.runBasisModelAnalysis(states, hh)
# end

## loadHMM and data
hmm1 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(1)//basismodel_states(1)")
hmm50 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(50)//basismodel_states(50)")
hmm100 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(100)//basismodel_states(100)")
hmm150 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(150)//basismodel_states(150)")
hmm250 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(250)//basismodel_states(250)")

hmms = [hmm1, hmm50, hmm100, hmm150, hmm250]

include("data.jl");

## Generate Distro forecast
distributionForecastVector1 = HMM_Forecast.createSeveralOneStepPredictions(hmm1, dataTrainingAsIndeces, dataTestAsIndeces)::Vector{Vector{Float32}};
distributionForecastVector150 = HMM_Forecast.createSeveralOneStepPredictions(hmm150, dataTrainingAsIndeces, dataTestAsIndeces)::Vector{Vector{Float32}};

## Update Plots
hmm = hmm50
N = 50

prevTime = now()
println("-------------- Calc forecast distribution for {$N} states------------------")
distributionForecastVector = HMM_Forecast.createSeveralOneStepPredictions(hmm, dataTrainingAsIndeces, dataTestAsIndeces)::Vector{Vector{Float32}};
prevTime = HMM_Forecast.printTimeAndResetTimeStamp(prevTime)

println("-------------- Generate PIT plots for {$N} states------------------")
pitYear = HMM_Forecast.plotPIT(hmm, dataTests, distributionForecastVector, "PIT of Year 2020")
pitSpring = HMM_Forecast.plotPIT(hmm, observations[indecesSpring20], distributionForecastVector[indecesSpring20 .- (startIndexTest-1)], "Spring")
pitSummer = HMM_Forecast.plotPIT(hmm, observations[indecesSummer20], distributionForecastVector[indecesSummer20 .- (startIndexTest-1)], "Summer")
pitFall = HMM_Forecast.plotPIT(hmm, observations[indecesFall20], distributionForecastVector[indecesFall20 .- (startIndexTest-1)], "Fall")
pitWinter = HMM_Forecast.plotPIT(hmm, observations[indecesWinter20], distributionForecastVector[indecesWinter20 .- (startIndexTest-1)], "Winter")
pitSeasons = plot(pitSpring, pitSummer, pitFall, pitWinter, layout=(2,2))
pit0300 = HMM_Forecast.plotPIT(hmm, dataTests[1+3*4:96:end], distributionForecastVector[1+3*4:96:end], "03:00")
pit0900 = HMM_Forecast.plotPIT(hmm, dataTests[1+9*4:96:end], distributionForecastVector[1+9*4:96:end], "09:00")
pit01500 = HMM_Forecast.plotPIT(hmm, dataTests[1+15*4:96:end], distributionForecastVector[1+15*4:96:end], "15:00")
pit2100 = HMM_Forecast.plotPIT(hmm, dataTests[1+21*4:96:end], distributionForecastVector[1+21*4:96:end], "21:00")
pitSpecificTimes = plot(pit0300, pit0900, pit01500, pit2100, layout=(2,2))
png(pitYear, ".//HMM_Forecast//tmp//basismodel_hh($hh)//states($N)//pitYear.png")
png(pitSpecificTimes, ".//HMM_Forecast//tmp//basismodel_hh($hh)//states($N)//pitSpecificTimes.png")
png(pitSeasons, ".//HMM_Forecast//tmp//basismodel_hh($hh)//states($N)//pitSeasons.png")
prevTime = HMM_Forecast.printTimeAndResetTimeStamp(prevTime)


## Plot Vergleiche
x = 87043
T = 20
H = 30

HMM_Forecast.plotDistributionForecastWithViolin(hmm1, observations[x-H-T+1:x-H], observations[x-H+1:x], distributionForecastVector1[(x-H+1:x) .- (startIndexTest-1)], "1") |> display
HMM_Forecast.plotDistributionForecastWithViolin(hmm150, observations[x-H-T+1:x-H], observations[x-H+1:x], distributionForecastVector150[(x-H+1:x) .- (startIndexTest-1)], "150") |> display
HMM_Forecast.plotPIT(hmm1, observations[x-H+1:x], distributionForecastVector1[(x-H+1:x) .- (startIndexTest-1)], "1") |> display
HMM_Forecast.plotPIT(hmm150, observations[x-H+1:x], distributionForecastVector150[(x-H+1:x) .- (startIndexTest-1)], "150") |> display

## Calc Loglikelihood
f_train(hmm_abstract) = HMM_Forecast.forwardAlgo(hmm_abstract, dataTrainingAsIndeces)[2]
f_test(hmm_abstract) = HMM_Forecast.forwardAlgo(hmm_abstract, dataTestAsIndeces)[2]
loglikelihood_train = map(f_train, hmms)
loglikelihood_test = map(f_test, hmms)

## Calc average relative Mean error
calcPrediction(hmm) =  HMM_Forecast.createSeveralOneStepPredictions(hmm, dataTrainingAsIndeces, dataTestAsIndeces)::Vector{Vector{Float32}};
calcMeanError_test(hmm) = HMM_Forecast.calcAverageRelativeMeanError(hmm.observationSpace, dataTestAsIndeces, calcPrediction(hmm))

meanError_test = map(calcMeanError_test, hmms)

