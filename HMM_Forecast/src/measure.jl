# File for measure implementations.

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
