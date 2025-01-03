include("../src/HMM.jl")

using Main.HMM

# Set Paramets
N = 2;
forecastHorizon = 30;
iter = 60;

# load Data 2 Months
(observationSpace, observationsAsIndeces) = Main.HMM.Data.getTestData2Month();

# Load pretrained hmm
hmmMonth2_100states_30iter = Main.HMM.Data.loadHMM("hmm_2Month_States(100)_(30)_1");
hmmMonth2_100states_60iter = Main.HMM.Data.loadHMM("hmm_2Month_States(100)_(60)");
hmmMonth2_100states_90iter = Main.HMM.Data.loadHMM("hmm_2Month_States(100)_(90)");
#hmmMonth2_200states_60iter = Main.HMM.Data.loadHMM("hmm_2Month_States(200)_(60)_1");

hmm = hmmMonth2_100states_90iter;

# Run BW-Algo with random initHMM
hmm, logliklihood_hmm = Main.HMM.Prod.runBWAlgoWithRandomInit((observationSpace, observationsAsIndeces), N, 100);
Main.HMM.Data.saveHMM(hmm, "hmm_2Month_States($N)_($(iter))_1")

# # Run BW Algo with initHMM

hmm, logliklihood_hmm = Main.HMM.Prod.runBWAlgoWithGivenInit(observationsAsIndeces, hmmMonth2_10states_60iter, iter);
Main.HMM.Data.saveHMM(hmm, "hmm_2Month_States($N)_($(iter+60))")



# Calc best path forecast
forecastAsIndeces, likelihood_forecast = Main.HMM.Calc.bestPathPrognosis(hmm, observationsAsIndeces, forecastHorizon)
forecast = Main.HMM.Helpers.translateIndexToObservations(forecastAsIndeces, observationSpace)
observations = Main.HMM.Helpers.translateIndexToObservations(observationsAsIndeces, observationSpace)

# plot forecast
Main.HMM.Plot.plotForecast(observations, forecast)
println(forecastAsIndeces)
println(observations[4900:5000])
println(hmm.observationMatrix.transitionMatrix[:,104])

hmm.observationMatrix.transitionMatrix[:, 104] |> sum