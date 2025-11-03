# File for measure implementations.
using LinearAlgebra

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

# Returns the quantile of the realization in the forecasted distribution
## Calculates the quantile of the continuous linearised distribution
function quantileForecastContinuous((observationSpace, infoBin), (distribution, distributionCDF), quantile)::Float32
    correspondingBin = searchsortedfirst(distributionCDF, quantile) # returns first bin, where the quantile is lower than the discrete cdf value
    # infoBin[1] = left bound of bin; infoBin[2] = length of bin
    # => quantile = left bound + length of bin * Relation Factor of Quantile Position inside the bin (0=left; 1=right)
    quantForecast = infoBin[correspondingBin][1] + infoBin[correspondingBin][2]*(1 - (distributionCDF[correspondingBin] - quantile)/(distribution[correspondingBin]))
    
    return quantForecast
end

# Calculates the PIT
# uses information about the observationSpace/Discretization, the forecasted distribution and the observation.
function pitValue((observationSpace, infoBins, rightNodes), (distribution, distributionCDF), observation)
    correspondingBin = searchsortedfirst(rightNodes, observation)   # bin in which observation lies
    ratio = (observation - infoBins[correspondingBin][1])/infoBins[correspondingBin][2] # where exactly the observation lies in the bin relatively
    if ratio < 0 
        throw(DomainError("ratio negativ."))
    end
    distributionCDFWithZero = vcat(0, distributionCDF)
    pit = distributionCDFWithZero[correspondingBin] + distribution[correspondingBin]*ratio # probability of all bins before + part of bin probability calculated linearly 
    return pit
end

#----------------------------------------------------------------------
## Scoring rules
function pinballScore(quantForecast, observation, quantile)
    if quantForecast >= observation
        return (1 - quantile)*(quantForecast- observation)
    elseif quantForecast < observation
        return quantile*(observation - quantForecast)
    else
        println("FAIL!")
    end
end

function crpsScore(quantileForecasts, observation)
    crps = 0.
    for (i, quantile) in enumerate(0.01:0.01:0.99)
        crps += pinballScore(quantileForecasts[i], observation, quantile)
    end
    return crps
end

function pinballContinuous((observationSpace, infoBins), observation, (distribution, distributionCDF), quantile::Float64)
    quantForecast = quantileForecastContinuous((observationSpace, infoBins), (distribution, distributionCDF), quantile)
    score = pinballScore(quantForecast, observation, quantile)
    return score
end

# Calculates the mean CRPS based on the distribution vector over the discretized observation Space
# The continuous version continuousizes the discrete distribution
function crpsContinuous((observationSpace, infoBins), observation, distribution::Vector{Float64})
    distributionCDF = cumsum(distribution)
    distributionCDF[end] = 1.
    quantiles = 0.01:0.01:0.99
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
function loglikelihood(hmm::HMM, observationsAsIndeces)::Float64
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

function meanCRPSContinuous((observationSpace, infoBins), observations, distributionVector::Vector{Vector{Float64}})::Float64
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

##### Function to find convergences point of stochastic Vectors
function calcConcergencePoint(hmm, forecastVector, atol=0.01)
    stationaryDistro = calcStationaryDistribution(hmm)' * hmm.observationMatrix.transitionMatrix |> vec

    for H in eachindex(forecastVector)
        curr = forecastVector[H]
        d = LinearAlgebra.norm1(curr .- stationaryDistro)
        if d < atol
            return H
        end
    end
    return NaN

    throw(ArgumentError("Erwarte Matrix (Spalten = Folge) oder Vector von Vektoren."))
end

"""
    convergence_point(forecastVector; reltol=0.01)

Bequemer Wrapper, der nur den Vektor am Konvergenzpunkt zurückgibt (oder `nothing`).
"""
function convergence_point(forecastVector; reltol=0.01)
    res = convergence_index(forecastVector; reltol=reltol)
    res === nothing ? nothing : res.vector
end

# -----------------------------------------------
# LEGACY CODE

function crps(observationSpace::ObservationSpace, observation, distribution::Vector{Float64})
    quantiles = 0.01:0.01:1.
    crps = 0.
    for quantile in quantiles
        crps += pinball(observationSpace, observation, distributionCDF, quantile)
    end
    return crps
end

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

function quantileForecast(observationSpace::ObservationSpace, distribution::Vector{Float64}, quantile)::Int64
    frequencyVector =  transformDistributionVectorToFrequencyVector(observationSpace, distribution)
    n = length(frequencyVector) * quantile |> ceil |> Int
    forecast = sort(frequencyVector)[n]
    return forecast
end


## Quantile functions
function empiricQuantile(observationSpace::ObservationSpace, distribution::Vector{Float64}, observation)::Float64
    f(x) = (x<= observation)
    frequencyVector =  transformDistributionVectorToFrequencyVector(observationSpace, distribution)
    quantile = count(f, frequencyVector)/length(frequencyVector)
    return quantile
end