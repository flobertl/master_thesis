# Productive functions
using HiddenMarkovModels: HMM as HMMPkg, baum_welch as BWAlgoPkg

export runBWAlgoWithRandomInit, runBestPathPrognosis,forwardAlgo, runSingleTrainingPkg

function runBWAlgoWithRandomInit((observationSpace, observationsAsIndeces), numberStates, maxIter::Int = 100)
    N = numberStates
    initHMM = createRandomHMM(N, observationSpace)
    baumWelchAlgo(initHMM, observationsAsIndeces, maxIter)
end 

function createSeveralOneStepPredictions(hmm::HMM, histObservationsAsIndeces, futureObservationsAsIndeces)::Vector{Vector{Float64}}
    H = length(futureObservationsAsIndeces)
    forecastVector = Vector{Vector{Float64}}(undef, H)
    alpha_init = forwardAlgo(hmm, histObservationsAsIndeces)[1][end,:]
    for h in 1:H
        (forecastVectorOfVector, alpha_i_beforeNewInfo) = forecastDistributionWithAlpha(hmm, 1, alpha_init)
        alpha_i_afterNewInfo = alpha_i_beforeNewInfo .* hmm.observationMatrix.transitionMatrix[:, futureObservationsAsIndeces[h]]
        normalisingFactor = sum(alpha_i_afterNewInfo)
        alpha_init = alpha_i_afterNewInfo ./ normalisingFactor
        forecastVector[h] = forecastVectorOfVector[1]
   end
    return forecastVector
end

function calcSlidingWindowPrediction(hmm::HMM, observationDataAsIndeces::Vector{Int}, historicWindowLength::Int, testDataIndeces::Vector{Int})::Vector{Vector{Float64}}
    forecastVector = Vector{Vector{Float64}}(undef, length(testDataIndeces))
    for (i, testIndex) in enumerate(testDataIndeces)
        forecastVector[i] = forecastDistribution(hmm, observationDataAsIndeces[testIndex-historicWindowLength:testIndex-1], 1)[1]
    end
    return forecastVector
end
