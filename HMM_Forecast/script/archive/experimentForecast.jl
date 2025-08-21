using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise
using HMM_Forecast

using Plots
# Set Paramets
hh = 1

# load Data 2 Months
include("data.jl");
(observationSpace, observationsAsIndeces) = getTestData2Month();


# Load pretrained hmm
# hmmMonth2_100states_30iter = HMM_Forecast.loadHMM("hmm_2Month_States(100)_(30)_1");
# hmmMonth2_100states_60iter = HMM_Forecast.loadHMM("hmm_2Month_States(100)_(60)");
# hmmMonth2_100states_90iter = HMM_Forecast.loadHMM("hmm_2Month_States(100)_(90)");
# #hmmMonth2_200states_60iter = HMM_Forecast.loadHMM("hmm_2Month_States(200)_(60)_1");
# hmm2years_100states_100iter = HMM_Forecast.loadHMM("hmm_2years_States(100)_(100)_1");
# hmm2years_100states_100iter = HMM_Forecast.loadHMM("hmm_2years_states(100)_iter(100)_hh(1)_version(1)");
#hmm2years_200states_50iter = HMM_Forecast.loadHMM("hmm_2years_states(200)_iter(50)_hh(2)_version(1)");
hmm2years_300states_100iter_WithTimesteps = HMM_Forecast.loadHMM("hmm_2years_states(300)_iter(100)_hh(2)_version(1)_observationsStates(651)_withtimestamps")
# hmm2years_300states_50iter_everyQH = HMM_Forecast.loadHMM("hmm_2years_states(300)_iter(50)_hh(2)_version(1)_observationsStates(1934)_withtimestamps")
#hmm2years_300states_50iter_everyQH = HMM_Forecast.loadHMM("hmm_2years_states(200)_iter(20)_hh(2)_version(2)_observationsStates(1802)_withtimestampseachQH")
hmm40 = HMM_Forecast.loadHMM("simplified_experiments/basismodel_hh(1)//basismodel_states(50)")
# hmm100 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(100)//basismodel_states(100)")
# hmm150 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(150)//basismodel_states(150)")
# hmm250 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(250)//basismodel_states(250)")
# hmm200 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(200)//basismodel_states(200)")
# hmm300 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(300)//basismodel_states(300)")


hmm = hmm40

#Run BW-Algo with random initHMM
T = 5000
N = 200
iter = 20
# hmm, logliklihood_hmm = HMM_Forecast.runBWAlgoWithRandomInit((observationSpace, observationsAsIndeces[1:T]), N, iter);
#HMM_Forecast.saveHMM(hmm, "test//hmm_2years_states($N)_iter($(iter))_hh($hh)_version(2)_observationsStates($(hmm.observationSpace.dimension))_withtimestampseachQH")

# # # Run BW Algo with given initHMM
# hmm, logliklihood_hmm = HMM_Forecast.runBWAlgoWithGivenInit(observationsAsIndeces, hmm2years_100states_100iter, 4);
# saveHMM(hmm, "hmm_2Month_States($N)_($(iter+60))")

# Parameters
x = 9000
H = 10
T = 20

# Calc best path forecast
forecastAsIndeces, likelihood_forecast = HMM_Forecast.bestPathPrognosis(hmm, observationsAsIndeces[1:x-T], H)
forecast = HMM_Forecast.translateIndexToObservations(forecastAsIndeces, observationSpace)

# # plot forecast
HMM_Forecast.plotForecast(observations[1:end-96], forecast)


# # hmm.observationMatrix.transitionMatrix[:, 104] |> sum
#  HMM_Forecast.plotForecastSlidingWindow(hmm, observations[end-960-65:end], 10, 970)

# Calc Distribution Forecast
x = 9000
H = 10
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