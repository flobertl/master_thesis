# Benchmarking models

# Baseline
function generate96qhDistro(observationSpace::ObservationSpace, trainData)::Vector{Vector{Float64}}
    M = observationSpace.dimension
    observations = translateIndexToObservations(collect(1:M), observationSpace)
    
    distributionPerQuarterHour = Vector{Vector{Float64}}(undef, 96)
    for qh in 1:96 
        numberOfQH = length(trainData[qh:96:end])
        distributionPerQuarterHour[qh] = map(i -> count(obser -> obser == observations[i], trainData[qh:96:end])/numberOfQH, 1:M)
        if sum(distributionPerQuarterHour[qh]) != 1
            println("Value qh($qh) is $(sum(distributionPerQuarterHour[qh]))")
        end
    end
    return distributionPerQuarterHour
end

function generateBaselineForecast(observationSpace, trainData, H::Int64)::Vector{Vector{Float64}}
    quarterHourProb = generate96qhDistro(observationSpace, trainData)
    forecast = map(i -> quarterHourProb[i % 96 + 1], 1:H)
    return forecast
end

# Naive Predictor

function naivePrediction(trainData, testData)
    naivePred = [trainData[end]]
    for i in 2:length(testData)
        push!(naivePred, testData[i-1])
    end
    return naivePred
end

function evalPointForecast(observations, pointForecast)
    H = length(pointForecast)
    relativeErrors = zeros(Float64, H)
    for i in 1:H
        relativeErrors[i] = (pointForecast[i] - observations[i])/observations[i] |> abs
    end
    return sum(relativeErrors)/H
end