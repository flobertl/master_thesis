include("../src/HMM.jl")

using StatsPlots

(observationSpace, observationsAsIndeces) = Main.HMM.Data.getTestDataDay()
observations =  Main.HMM.Helpers.translateIndexToObservations(observationsAsIndeces, observationSpace)
# Set Parameter
N = 10
initHMM =  Main.HMM.Helpers.createRandomHMM(N, observationSpace)

# Run Algo
hmm1, logliklihood =  Main.HMM.Calc.baumWelchAlgo(initHMM, observationsAsIndeces, 10)

n = length(observationsAsIndeces)
H = 4
indexHist = 1:(n-H)
indexFuture = (n-H+1):n

forecast = Main.HMM.Calc.forecastDistribution(hmm1, observationsAsIndeces[indexHist], H)
p = Main.HMM.Plot.plotDistributionForecastWithViolin(hmm1, observations[indexHist], observations[indexFuture], forecast)


