## Pkg
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Plots
using HMM_Forecast

## loadHMM and data
hmm1 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(1)//basismodel_states(1)")
hmm50 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(50)//basismodel_states(50)")
hmm100 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(100)//basismodel_states(100)")
hmm150 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(150)//basismodel_states(150)")
hmm250 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(250)//basismodel_states(250)")
hmm200 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(200)//basismodel_states(200)")
hmm300 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(300)//basismodel_states(300)")

hmms = [(hmm50, 50), (hmm100, 100), (hmm150, 150), (hmm200, 200), (hmm250, 250), (hmm300, 300)]

## Load Data
hh = 1
include("data.jl");

## Update Plots
function analysisYear((hmm_original, N))
    hmm = hmm_original |> HMM_Forecast.updateHMMNumericalStable
    prevTime = now()
    println("-------------- Calc forecast distribution for {$N} states------------------")
    distributionForecastVector = HMM_Forecast.createSeveralOneStepPredictions(hmm, dataTrainingAsIndeces, dataTestAsIndeces)::Vector{Vector{Float64}};
    prevTime = HMM_Forecast.printTimeAndResetTimeStamp(prevTime)

    println("-------------- Generate PIT plots for {$N} states------------------")
    pitYear = HMM_Forecast.plotPIT(hmm, dataTests, distributionForecastVector, "Year 2020 (basismodel 300states)")
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
end

map(analysisYear, hmms)

# ## Plot Vergleiche
# x = 87043
# T = 20
# H = 30

# HMM_Forecast.plotDistributionForecastWithViolin(hmm1, observations[x-H-T+1:x-H], observations[x-H+1:x], distributionForecastVector1[(x-H+1:x) .- (startIndexTest-1)], "1") |> display
# HMM_Forecast.plotDistributionForecastWithViolin(hmm150, observations[x-H-T+1:x-H], observations[x-H+1:x], distributionForecastVector150[(x-H+1:x) .- (startIndexTest-1)], "150") |> display
# HMM_Forecast.plotPIT(hmm1, observations[x-H+1:x], distributionForecastVector1[(x-H+1:x) .- (startIndexTest-1)], "1") |> display
# HMM_Forecast.plotPIT(hmm150, observations[x-H+1:x], distributionForecastVector150[(:x) .- (startIndexTest-1)], "150") |> display

## Calc Loglikelihood
f_train((hmm_abstract, N)) = println(now()); HMM_Forecast.forwardAlgo(hmm_abstract |> HMM_Forecast.updateHMMNumericalStable, dataTrainingAsIndeces)[2]
f_test((hmm_abstract, N)) = HMM_Forecast.forwardAlgo(hmm_abstract |> HMM_Forecast.updateHMMNumericalStable, dataTestAsIndeces)[2]
loglikelihood_train = map(f_train, hmms)
loglikelihood_test = map(f_test, hmms)

for i in 1:6
    println("Basismodel $(hmms[i][2]) states --- Likelihood Train: $(loglikelihood_train[i]); Likelihood Test $(loglikelihood_test[i])")
end

## Calc average relative Mean error
calcPrediction(hmm) =  HMM_Forecast.createSeveralOneStepPredictions(hmm, dataTrainingAsIndeces, dataTestAsIndeces)::Vector{Vector{Float64}};
calcMeanError_test((hmm, N)) = HMM_Forecast.calcAverageRelativeMeanError(hmm.observationSpace, dataTestAsIndeces, calcPrediction(hmm))

meanError_test = map(calcMeanError_test, hmms)

println("Average relative mean error")
for i in 1:6
    println("Basismodel $(hmms[i][2]) states --- ARME: $(meanError_test[i])")
end 
