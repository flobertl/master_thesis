# File for measure implementations.

## Distribution measures
function mean(observationSpace::ObservationSpace, distribution::Vector{Float64})
    M = observationSpace.dimension
    mean = [observationSpace.mapIndexToObservation[i] for i in 1:M]' * distribution
    return mean
end

function variance(observationSpace::ObservationSpace, distribution::Vector{Float64})
    M = observationSpace.dimension
    mean = [observationSpace.mapIndexToObservation[i] for i in 1:M]' * distribution
    exp_Xpow2 = [observationSpace.mapIndexToObservation[i]^2 for i in 1:M]' * distribution
    return exp_Xpow2 - mean^2
end

## Quantile functions
function empiricQuantile(observationSpace::ObservationSpace, distribution::Vector{Float64}, observation)::Float64
    f(x) = (x<= observation)
    frequencyVector =  transformDistributionVectorToFrequencyVector(observationSpace, distribution)
    quantile = count(f, frequencyVector)/length(frequencyVector)
    return quantile
end

function quantileForecast(observationSpace::ObservationSpace, distribution::Vector{Float64}, quantile)::Int64
    frequencyVector =  transformDistributionVectorToFrequencyVector(observationSpace, distribution)
    n = length(frequencyVector) * quantile |> ceil |> Int
    forecast = sort(frequencyVector)[n]
    return forecast
end

## Scoring rules
function pinball(observationSpace::ObservationSpace, observation, distribution::Vector{Float64}, quantile::Float64)
    quantForecast = quantileForecast(observationSpace, distribution, quantile)
    if quantForecast >= observation
        return (1 - quantile)*(quantForecast- observation)
    elseif quantForecast < observation
        return quantile*(observation - quantForecast)
    else
        println("FAIL!")
    end
end

function crps(observationSpace::ObservationSpace, observation, distribution::Vector{Float64})
    quantiles = 0.01:0.01:1.
    crps = 0.
    for quantile in quantiles
        crps += pinball(observationSpace, observation, distribution, quantile)
    end
    return crps
end

## Eval forecast Vectors
function loglikelihood(hmm::HMM, observations::Vector{Int64})::Float64
    observationsAsIndeces = translateObservationsToIndex(observations, hmm.observationSpace)
    alpha, loglikelihood = forwardAlgo(hmm, observationsAsIndeces)
    return loglikelihood
end 

function meanCRPS(observationSpace::ObservationSpace, observations::Vector{Int64}, distributionVector::Vector{Vector{Float64}})::Float64
    T = length(observations)
    if T != length(distributionVector)
        throw(DimensionMismatch("$distributionVector and $observations"))
    end
    meanCRPS = 0
    for t in 1:T
        meanCRPS +=  crps(observationSpace, observations[t], distributionVector[t])
    end
    return meanCRPS/T
end

function mae_forMeanPointForecast(observationSpace::ObservationSpace, observations::Vector{Int64}, distributionVector::Vector{Vector{Float64}})::Float64
    H = length(observations)
    means = map(distro -> (mean(observationSpace, distro)), distributionVector)::Vector{Float64}
    result = abs.( (observations - means)) |> sum
    return result/H
end

function r_squared_forMeanPointForecast(observationSpace::ObservationSpace, observations::Vector{Int64}, forecastVector::Vector{Vector{Float64}})::Float64
    H = length(observations)
    pointForecast = map(distro -> mean(observationSpace, distro), forecastVector)
    meanObs = sum(observations)/H
    SS_res = map(i -> (observations[i] - pointForecast[i])^2, 1:H) |> sum
    SS_tot = map(i -> (observations[i] - meanObs)^2, 1:H) |> sum
    return 1 - SS_res/SS_tot
end
