## Pkg
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Plots
using HMM_Forecast

hh = 2
include("data.jl")
trainData = dataTrainingFullYear
testData = dataTestsFullYear

# ## loadHMM and data
# hmm1 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(1)//basismodel_states(1)")
# hmm10 = HMM_Forecast.loadHMM("basismodel_hh($hh)//states(10)//basismodel_states(10)")
# hmm50 = HMM_Forecast.loadHMM("basismodel_hh($hh)//states(50)//basismodel_states(50)")
# hmm100 = HMM_Forecast.loadHMM("basismodel_hh($hh)//states(100)//basismodel_states(100)")
# hmm150 = HMM_Forecast.loadHMM("basismodel_hh($hh)//states(150)//basismodel_states(150)")
# hmm250 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(250)//basismodel_states(250)")
# hmm200 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(200)//basismodel_states(200)")
# hmm300 = HMM_Forecast.loadHMM("basismodel_hh(1)//states(300)//basismodel_states(300)")

hmmBasis2(n) = HMM_Forecast.loadHMM("basismodel_hh(2)//basismodel_states($n)")

#hmms = [(hmm50, 50), (hmm100, 100), (hmm150, 150), (hmm200, 200), (hmm250, 250), (hmm300, 300)]

numbersOfStates = [1, 3, 5, 7, 10, 15, 20, 30, 40, 50, 60]
evalResult = []
## Evaluate models
for i in 1:11
    hmm = hmmBasis2(numbersOfStates[i])
    push!(evalResult, HMM_Forecast.calcEvaluation(hmm, trainData, testData))
end
for i in 1:11
    HMM_Forecast.printEvaluation("Basismodel States($(numbersOfStates[i]))", evalResult[i])
end


# ## Calc Loglikelihood
# f_train((hmm_abstract, N)) = println(now()); HMM_Forecast.forwardAlgo(hmm_abstract |> HMM_Forecast.updateHMMNumericalStable, dataTrainingAsIndeces)[2]
# f_test((hmm_abstract, N)) = HMM_Forecast.forwardAlgo(hmm_abstract |> HMM_Forecast.updateHMMNumericalStable, dataTestAsIndeces)[2]
# loglikelihood_train = map(f_train, hmms)
# loglikelihood_test = map(f_test, hmms)

# for i in 1:6
#     println("Basismodel $(hmms[i][2]) states --- Likelihood Train: $(loglikelihood_train[i]); Likelihood Test $(loglikelihood_test[i])")
# end

# ## Calc average relative Mean error


# calcMeanError_test((hmm, N)) = HMM_Forecast.calcAverageRelativeMeanError(hmm.observationSpace, dataTestAsIndeces, calcPrediction(hmm))

# meanError_test = map(calcMeanError_test, hmms)

# println("Average relative mean error")
# for i in 1:6
#     println("Basismodel $(hmms[i][2]) states --- ARME: $(meanError_test[i])")
# end 
