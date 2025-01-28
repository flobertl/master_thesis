using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise
using HMM_Forecast

using Plots
# Set Paramets
hh = 2

# load Data 2 Months
(observationSpace, observations, observationsAsIndeces) = HMM_Forecast.getData2Years_EveryQHTimestamps(hh);
# (observationSpace, observationsAsIndeces) = getTestData2Month();


# Load pretrained hmm
# hmmMonth2_100states_30iter = HMM_Forecast.loadHMM("hmm_2Month_States(100)_(30)_1");
# hmmMonth2_100states_60iter = HMM_Forecast.loadHMM("hmm_2Month_States(100)_(60)");
# hmmMonth2_100states_90iter = HMM_Forecast.loadHMM("hmm_2Month_States(100)_(90)");
# #hmmMonth2_200states_60iter = HMM_Forecast.loadHMM("hmm_2Month_States(200)_(60)_1");
# hmm2years_100states_100iter = HMM_Forecast.loadHMM("hmm_2years_States(100)_(100)_1");
# hmm2years_100states_100iter = HMM_Forecast.loadHMM("hmm_2years_states(100)_iter(100)_hh(1)_version(1)");
#hmm2years_200states_50iter = HMM_Forecast.loadHMM("hmm_2years_states(200)_iter(50)_hh(2)_version(1)");
# hmm2years_300states_100iter_WithTimesteps = HMM_Forecast.loadHMM("hmm_2years_states(300)_iter(100)_hh(2)_version(1)_observationsStates(651)_withtimestamps")
# hmm2years_300states_50iter_everyQH = HMM_Forecast.loadHMM("hmm_2years_states(300)_iter(50)_hh(2)_version(1)_observationsStates(1934)_withtimestamps")
hmm2years_300states_50iter_everyQH = HMM_Forecast.loadHMM("hmm_2years_states(200)_iter(20)_hh(2)_version(2)_observationsStates(1802)_withtimestampseachQH")

hmm = hmm2years_300states_50iter_everyQH 

#Run BW-Algo with random initHMM
# T = 5000
# N = 200
# iter = 20
# hmm, logliklihood_hmm = HMM_Forecast.runBWAlgoWithRandomInit((observationSpace, observationsAsIndeces[1:T]), N, iter);
# saveHMM(hmm, "hmm_2years_states($N)_iter($(iter))_hh($hh)_version(2)_observationsStates($(hmm.observationSpace.dimension))_withtimestampseachQH")

# # # Run BW Algo with given initHMM
# hmm, logliklihood_hmm = HMM_Forecast.runBWAlgoWithGivenInit(observationsAsIndeces, hmm2years_100states_100iter, 4);
# saveHMM(hmm, "hmm_2Month_States($N)_($(iter+60))")

# Calc best path forecast
# forecastAsIndeces, likelihood_forecast = bestPathPrognosis(hmm, observationsAsIndeces[1:2000-96], 96)
# forecast = HMM_Forecast.translateIndexToObservations(forecastAsIndeces, observationSpace)

# # # plot forecast
# HMM_Forecast.plotForecast(observations[90000:end-96], forecast)


# # hmm.observationMatrix.transitionMatrix[:, 104] |> sum
#  HMM_Forecast.plotForecastSlidingWindow(hmm, observations[end-960-65:end], 10, 970)

# Calc Distribution Forecast
x = 1000
H = 30
T = 20
forecast = HMM_Forecast.forecastDistribution(hmm, observationsAsIndeces[1:x-H], H)

observations = HMM_Forecast.translateIndexToObservations(observationsAsIndeces[1:x], observationSpace)
p = HMM_Forecast.plotDistributionForecastWithViolin(hmm, observations[x-H-T+1:x-H], observations[x-H+1:x], forecast[1:end])


# Evaluate daily routine 
startValue = observations[end-H] % 100
arrayOfTruth = [(startValue, 1000, 0)]
for i in 1:20 
    trueValue = observations[end-H+i] % 100
    x1 = HMM_Forecast.transformDistributionVectorToFrequencyVector(observationSpace, forecast[i])
    countOfExpectedValue = count( ==(trueValue), x1 .% 100)
    countOfNonExpectedValues = count( !=(trueValue), x1 .% 100)
    push!(arrayOfTruth, (trueValue, countOfExpectedValue, countOfNonExpectedValues))
end

print(arrayOfTruth)