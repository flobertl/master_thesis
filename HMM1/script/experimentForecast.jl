include("../src/HMM.jl")

using Main.HMM
using Plots
# Set Paramets
hh = 2

# load Data 2 Months
(observationSpace, observations, observationsAsIndeces) = Main.HMM.Data.getData2Years_EveryQHTimestamps(hh);
# (observationSpace, observationsAsIndeces) = Main.HMM.Data.getTestData2Month();


# # plot observations
# X = 10
# T = 96*7
# W = 96*7
# violin(observations, ylims = (0,6000))
# totalWeeks = 50
# agregated = zeros(Float32, T)
# for i in 1:totalWeeks
#     observations = Main.HMM.Helpers.translateIndexToObservations(observationsAsIndeces[W*i+1:T+W*i], observationSpace)
#     agregated = agregated .+ (observations./totalWeeks)
# end

# plot1 = plot(1:T, agregated)
#plot!(1:T, observations[1+W*X:T+W*X], color = :red)

# Load pretrained hmm
# hmmMonth2_100states_30iter = Main.HMM.Data.loadHMM("hmm_2Month_States(100)_(30)_1");
# hmmMonth2_100states_60iter = Main.HMM.Data.loadHMM("hmm_2Month_States(100)_(60)");
# hmmMonth2_100states_90iter = Main.HMM.Data.loadHMM("hmm_2Month_States(100)_(90)");
# #hmmMonth2_200states_60iter = Main.HMM.Data.loadHMM("hmm_2Month_States(200)_(60)_1");
# hmm2years_100states_100iter = Main.HMM.Data.loadHMM("hmm_2years_States(100)_(100)_1");
# hmm2years_100states_100iter = Main.HMM.Data.loadHMM("hmm_2years_states(100)_iter(100)_hh(1)_version(1)");
#hmm2years_200states_50iter = Main.HMM.Data.loadHMM("hmm_2years_states(200)_iter(50)_hh(2)_version(1)");
# hmm2years_300states_100iter_WithTimesteps = Main.HMM.Data.loadHMM("hmm_2years_states(300)_iter(100)_hh(2)_version(1)_observationsStates(651)_withtimestamps")
# hmm2years_300states_50iter_everyQH = Main.HMM.Data.loadHMM("hmm_2years_states(300)_iter(50)_hh(2)_version(1)_observationsStates(1934)_withtimestamps")
hmm2years_300states_50iter_everyQH = Main.HMM.Data.loadHMM("hmm_2years_states(200)_iter(20)_hh(2)_version(2)_observationsStates(1802)_withtimestampseachQH")

hmm = hmm2years_300states_50iter_everyQH;

#Run BW-Algo with random initHMM
# T = 5000
# N = 200
# iter = 20
# hmm, logliklihood_hmm = Main.HMM.Prod.runBWAlgoWithRandomInit((observationSpace, observationsAsIndeces[1:T]), N, iter);
# Main.HMM.Data.saveHMM(hmm, "hmm_2years_states($N)_iter($(iter))_hh($hh)_version(2)_observationsStates($(hmm.observationSpace.dimension))_withtimestampseachQH")

# # # Run BW Algo with given initHMM
# hmm, logliklihood_hmm = Main.HMM.Prod.runBWAlgoWithGivenInit(observationsAsIndeces, hmm2years_100states_100iter, 4);
# Main.HMM.Data.saveHMM(hmm, "hmm_2Month_States($N)_($(iter+60))")

# Calc best path forecast
# forecastAsIndeces, likelihood_forecast = Main.HMM.Calc.bestPathPrognosis(hmm, observationsAsIndeces[1:2000-96], 96)
# forecast = Main.HMM.Helpers.translateIndexToObservations(forecastAsIndeces, observationSpace)

# # # plot forecast
# Main.HMM.Plot.plotForecast(observations[90000:end-96], forecast)


# # hmm.observationMatrix.transitionMatrix[:, 104] |> sum
#  Main.HMM.Plot.plotForecastSlidingWindow(hmm, observations[end-960-65:end], 10, 970)

# Calc Distribution Forecast
x = 1000
H = 30
T = 20
forecast = Main.HMM.Calc.forecastDistribution(hmm, observationsAsIndeces[1:x-H], H)

observations = Main.HMM.Helpers.translateIndexToObservations(observationsAsIndeces[1:x], observationSpace)
p = Main.HMM.Plot.plotDistributionForecastWithViolin(hmm, observations[x-H-T+1:x-H], observations[x-H+1:x], forecast[1:end])


# Evaluate daily routine 
startValue = observations[end-H] % 100
arrayOfTruth = [(startValue, 1000, 0)]
for i in 1:20 
    trueValue = observations[end-H+i] % 100
    x1 = Main.HMM.Helpers.transformDistributionVectorToFrequencyVector(observationSpace, forecast[i])
    countOfExpectedValue = count( ==(trueValue), x1 .% 100)
    countOfNonExpectedValues = count( !=(trueValue), x1 .% 100)
    push!(arrayOfTruth, (trueValue, countOfExpectedValue, countOfNonExpectedValues))
end

print(arrayOfTruth)