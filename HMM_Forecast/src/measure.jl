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

function argmaxDistro(observationSpace::ObservationSpace, distribution::Vector{Float64})
    argmaxPrediction = observationSpace.mapIndexToObservation[ argmax(distribution) ]
    return argmaxPrediction
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

function quantileForecastContinuous((observationSpace::ObservationSpace, infoBin),(distribution, distributionCDF), quantile)::Float32
    correspondingBin = searchsortedfirst(distributionCDF, quantile)
    quantForecast = infoBin[correspondingBin][1] + infoBin[correspondingBin][2]*(distributionCDF[correspondingBin] - quantile)/(distribution[correspondingBin])
    return quantForecast
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
        crps += pinball(observationSpace, observation, distributionCDF, quantile)
    end
    return crps
end

function pinballContinuous((observationSpace::ObservationSpace, infoBins::Array{Tuple{Float32, Float32}}), observation, (distribution, distributionCDF), quantile::Float64)
    quantForecast = quantileForecastContinuous((observationSpace, infoBins), distributionCDF, quantile)
    if quantForecast >= observation
        return (1 - quantile)*(quantForecast- observation)
    elseif quantForecast < observation
        return quantile*(observation - quantForecast)
    else
        println("FAIL!")
    end
end

function crpsContinuous((observationSpace::ObservationSpace, infoBins::Array{Tuple{Float32, Float32}}), observation, distribution::Vector{Float64})
    distributionCDF = cumsum(distribution)
    quantiles = 0.01:0.01:1.
    crps = 0.
    for quantile in quantiles
        crps += pinballContinuous((observationSpace, infoBins), observation, (distribution, distributionCDF), quantile)
    end
    return crps
end

## Transform forecast Vectors
function transformDistributionToMeanPointForecast(observationSpace::ObservationSpace, distributionVector::Vector{Vector{Float64}})
    meanForecast = map(distro -> (mean(observationSpace, distro)), distributionVector)::Vector{Float64}
    return meanForecast
end

function transformDistributionToBestPathPointForecast(observationSpace::ObservationSpace, distributionVector::Vector{Vector{Float64}})
    bestPathForecast = map(distro -> (argmaxDistro(observationSpace, distro)), distributionVector)::Vector{Int64}
    return bestPathForecast
end


## Eval forecast Vectors
function loglikelihood(hmm::HMM, observations::Vector{Float32})::Float64
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

function meanCRPSContinuous((observationSpace::ObservationSpace, infoBins), observations::Vector{Int64}, distributionVector::Vector{Vector{Float64}})::Float64
    T = length(observations)
    if T != length(distributionVector)
        throw(DimensionMismatch("$distributionVector and $observations"))
    end
    meanCRPS = 0
    for t in 1:T
        meanCRPS +=  crpsContinuous((observationSpace, infoBins), observations[t], distributionVector[t])
    end
    return meanCRPS/T
end

function mae_forPointForecast(observations::Vector{Int64}, predictions::Vector{Float64})::Float64
    H = length(observations)
    result = abs.( (observations - predictions)) |> sum
    return result/H
end

function accuracy_forPointForecast(observations::Vector{Int64}, predictions::Vector{Int64})::Float64
    H = length(observations)
    result = (observations .== predictions) |> sum
    return result/H
end

function calcKonfusionsMatrix(obserSpace::ObservationSpace, observationsAsIndeces::Vector{Int64}, predictionsAsIndeces::Vector{Int64})
    N = obserSpace.dimension
    konfusionsMatrix = zeros(Float64, (N, N))
    for (t, obserIndex) in enumerate(observationsAsIndeces)
        konfusionsMatrix[obserIndex, predictionsAsIndeces[t]] += 1
    end
    for i in 1:N 
        konfusionsMatrix[i, :] = konfusionsMatrix[i, :] ./ sum(konfusionsMatrix[i, :])
    end
    return konfusionsMatrix
end

function residualVariance_forPointForecast(observations::Vector{Int64}, predictions::Vector{Float64})::Float64
    H = length(observations)
    residuals = (predictions - observations)
    meanResidual = sum(residuals)/H
    empVarianceOfError = sum((residuals .- meanResidual).^2) / (H-1)
    return empVarianceOfError
end

function r_squared_forMeanPointForecast(observationSpace::ObservationSpace, observations::Vector{Int64}, forecastVector::Vector{Vector{Float64}})::Float64
    H = length(observations)
    pointForecast = map(distro -> mean(observationSpace, distro), forecastVector)
    meanObs = sum(observations)/H
    SS_res = map(i -> (observations[i] - pointForecast[i])^2, 1:H) |> sum
    SS_tot = map(i -> (observations[i] - meanObs)^2, 1:H) |> sum
    return 1 - SS_res/SS_tot
end
