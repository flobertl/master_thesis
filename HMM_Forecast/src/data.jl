using XLSX, DataFrames, Dates

# --------------------------------------------------------------------------
# Helpers

function discretize(observations)
    discreteObs = map(round, observations)
    return map(Int, discreteObs)
end

function roundToGivenDigit(x, stepWidth::Int)
    x_round = (x/stepWidth) |> round
    return map(Int, x_round*stepWidth)
end

function abstractLoadObservations(observation::Array{Int64})
    function abstractLoad(load::Int64) 
        # Unter 700 watt in 10er Schritten
        if load <= 700 
            load_abstract = roundToGivenDigit(load, 10)
        # Von 700 bis 1200 watt in 50er Schritten
        elseif load <= 1200
            load_abstract = roundToGivenDigit(load, 50)
        # Von 1200 bis 2500 in 100er Schritten
        elseif load <= 2500
            load_abstract = roundToGivenDigit(load, 100)
        # Ab 2500 in 300er Schritten
        else 
            load_abstract = roundToGivenDigit(load, 300)
        end
        return load_abstract
    end

    return abstractLoad.(observation)
end

function abstractLoadObservations_Simplified(observation::Array{Int64})
    function abstractLoad(load::Int64) 
        # Unter 700 watt in 10er Schritten
        if load <= 2500
            load_abstract = roundToGivenDigit(load, 100)
        # Ab 2500 in 300er Schritten
        else 
            load_abstract = roundToGivenDigit(load, 500)
        end
        return load_abstract
    end

    return abstractLoad.(observation)
end

function addTimestamps(timeGranularity::Int, observations::Array{Int})::Array{Int}
    times = 96/timeGranularity
    observationWithTimestamp = []
    count = 0
    for obser in observations
       obserWithTimestamp = obser + floor(count/times) |> Int
       push!(observationWithTimestamp, obserWithTimestamp)
       count += 1
       if count == 96
        count = 0
       end
    end
    return observationWithTimestamp
end

function addSeasonstamps(observations::Array{Int}, dates)::Array{Int}
    if length(observations) != length(dates)
        println("fail")
    end
    isSeason((lb, ub), t) = lb <= Dates.month(t) && Dates.month(t) <= ub
    isWinter((lb, ub), t) = lb <= Dates.month(t) || Dates.month(t) <= ub
    curry(f, arg1) = x -> f(arg1, x)
    indecesSpring = findall(curry(isSeason, (3,5)), dates)
    indecesSummer = findall(curry(isSeason, (6,8)), dates)
    indecesFall = findall(curry(isSeason, (9,11)), dates)
    indecesWinter = findall(curry(isWinter, (12,2)), dates)

    newObservations = copy(observations)
    newObservations[indecesSpring] += ones(length(indecesSpring))
    newObservations[indecesSummer] += ones(length(indecesSummer)) .* 2
    newObservations[indecesFall] += ones(length(indecesFall)) .* 3
    newObservations[indecesWinter] += ones(length(indecesWinter)) .* 4

    newObservations
end

# ------------------------------------------------------------------------------
# Productive Load data

function getData2Years(householdId::Int64)
    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/15households_2years.xlsx"
    df = DataFrame(XLSX.readtable(path, "Sheet1"))
    observations = df[:, string(householdId)]

    # Convert Data
    abstractObser = observations |> discretize |> abstractLoadObservations
    observationSpace = Set(abstractObser) |> ObservationSpace
    observationsAsIndeces = translateObservationsToIndex(abstractObser, observationSpace)

    return(observationSpace, abstractObser, observationsAsIndeces)
end

function getData2Years_Seasonstamps(householdId::Int64)
    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/15households_2years.xlsx"
    df = DataFrame(XLSX.readtable(path, "Sheet1"))
    observations = df[:, string(householdId)]

    # Convert Data
    abstractObser = observations |> discretize |> abstractLoadObservations
    abstractObserWithTimestamps = addSeasonstamps(abstractObser, dateTimesOf2YearsData())
    observationSpace = Set(abstractObserWithTimestamps) |> ObservationSpace
    observationsAsIndeces = translateObservationsToIndex(abstractObserWithTimestamps, observationSpace)

    return(observationSpace, abstractObserWithTimestamps, observationsAsIndeces)
end

function getData2Years_Simplified(householdId::Int64)
    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/15households_2years.xlsx"
    df = DataFrame(XLSX.readtable(path, "Sheet1"))

    observations = df[:, string(householdId)]

    # Convert Data
    abstractObser = observations |> discretize |> abstractLoadObservations_Simplified
    observationSpace = Set(abstractObser) |> ObservationSpace
    observationsAsIndeces = translateObservationsToIndex(abstractObser, observationSpace)

    return(observationSpace, abstractObser, observationsAsIndeces)
end

function getData2Years_SimplifiedAndTimestamps(householdId::Int64, numberOfTimeBlocks::Int64)
    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/15households_2years.xlsx"
    df = DataFrame(XLSX.readtable(path, "Sheet1"))

    observations = df[:, string(householdId)]

    # Convert Data
    abstractObser = observations |> discretize |> abstractLoadObservations_Simplified
    abstractObserWithTimestamps = addTimestamps(numberOfTimeBlocks, abstractObser)
    observationSpace = Set(abstractObserWithTimestamps) |> ObservationSpace
    observationsAsIndeces = translateObservationsToIndex(abstractObserWithTimestamps, observationSpace)

    return(observationSpace, abstractObserWithTimestamps, observationsAsIndeces)
end

function getData2Years_Timestamps(householdId::Int64, numberOfTimeBlocks::Int64)
    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/15households_2years.xlsx"
    df = DataFrame(XLSX.readtable(path, "Sheet1"))
    observations = df[:, string(householdId)]

    # Convert Data
    abstractObser = observations |> discretize |> abstractLoadObservations
    abstractObserWithTimestamps = addTimestamps(numberOfTimeBlocks, abstractObser)
    observationSpace = Set(abstractObserWithTimestamps) |> ObservationSpace
    observationsAsIndeces = translateObservationsToIndex(abstractObserWithTimestamps, observationSpace)

    return(observationSpace, abstractObserWithTimestamps, observationsAsIndeces)
end

function getData2Years_EveryQHTimestamps(householdId::Int64)
    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/15households_2years.xlsx"
    df = DataFrame(XLSX.readtable(path, "Sheet1"))

    observations = df[:, string(householdId)]

    # Convert Data
    abstractObser = observations |> discretize |> abstractLoadObservations_Simplified
    abstractObserWithTimestamps = addTimestamps(96, abstractObser)
    observationSpace = Set(abstractObserWithTimestamps) |> ObservationSpace
    observationsAsIndeces = translateObservationsToIndex(abstractObserWithTimestamps, observationSpace)

    return(observationSpace, abstractObserWithTimestamps, observationsAsIndeces)
end

#-------------------------------------------------------------------------
# Saving and Loading HMMs
function saveHMM(hmm::HMM, fileName::String)
    # path of directory
    folderPath = ".//HMM_Forecast//tmp//"
    filePath = joinpath(folderPath, fileName)

    N = string(hmm.numberOfStateSpace)

    open(filePath, "w") do io
        # Save numberOfStateSpace
        println(io, join(N))

        # Save transition matrix
        for row in eachrow(hmm.transitionMatrix.transitionMatrix)
            println(io, join(row, ","))
        end

        # Save observation matrix
        println(io, join(hmm.observationMatrix.dimension, ","))
        for row in eachrow(hmm.observationMatrix.transitionMatrix)
            println(io, join(row, ","))
        end

        # Starting startingDistribution
        println(io, join(hmm.startingDistribution.probabilities, ","))
        
        # Observation space
        println(io, join(hmm.observationSpace.observations, ","))
        println(io, join(["$key:$value" for (key, value) in hmm.observationSpace.mapObservationToIndex], ","))
    end
end
function loadHMM(fileName::String)
    # path of directory
    folderPath = ".//HMM_Forecast//tmp//"
    filePath = joinpath(folderPath, fileName)

    open(filePath, "r") do io
        # Read states
        N = parse(Int, readline(io))

        # Read transition matrix
        A_ = zeros(N, N)
        for i in 1:N
            str = split(readline(io), ",")
            A_[i,:] = parse.(Float64, str)
        end
        A_=A(N, A_)

        # Observation Matrix
        N, M = parse.(Int, split(readline(io), ","))
        B_ = zeros(N, M)
        for i in 1:N
            str = split(readline(io), ",")
            B_[i,:] = parse.(Float64, str)
        end
        B_ = B((N,M), B_)

        # Starting Distribution
        startDist = parse.(Float64, split(readline(io), ",")) |> StochasticVector

        # Observation space
        observations = parse.(Int, split(readline(io), ",")) |> Set
        pairs = split(readline(io), ",")
        # Process each pair and convert to key-value format
        key_value_pairs = [split(pair, ":") for pair in pairs]
        mapObserToIndex = Dict(parse(Int, kv[1]) => parse(Int, kv[2]) for kv in key_value_pairs)
        mapIndexToObser = Dict(parse(Int, kv[2]) => parse(Int, kv[1]) for kv in key_value_pairs)
        obsSpace = ObservationSpace(M, observations, mapObserToIndex, mapIndexToObser)
        return HMM(N, A_, B_, startDist, obsSpace)
    end
end

#-------------------------------------------------------------------------
# Translate distribution forecast from timestamps to original data

function mapTimestampToOriginalIndeces(obserSpaceTimestamps::ObservationSpace, obserSpaceOriginal::ObservationSpace)::Dict{Int,Int}
    numberOfTimeBlocks = obserSpaceTimestamps.dimension/obserSpaceOriginal.dimension
    mappingTimestampToOriginalIndeces = Dict()
    for indexTimestamp in 1:obserSpaceTimestamps.dimension
        timestampValue = obserSpaceTimestamps.mapIndexToObservation[indexTimestamp]
        originalValue = filter(observation -> observation <= timestampValue, obserSpaceOriginal.observations) |> maximum
        indexOriginal = obserSpaceOriginal.mapObservationToIndex[originalValue]
        mappingTimestampToOriginalIndeces[indexTimestamp] = indexOriginal
    end
    return mappingTimestampToOriginalIndeces
end

function translateTimestampsToOriginalDistributionForecast(obserSpaceTimestamps::ObservationSpace, obserSpaceOriginal::ObservationSpace, distributionForecastVector::Vector{Vector{Float64}})::Vector{Vector{Float64}}
    originalDistributionForecastVector = Vector()
    mappingTimestampToOriginalIndeces = mapTimestampToOriginalIndeces(obserSpaceTimestamps, obserSpaceOriginal)
    for timestampsDistributionForecast in distributionForecastVector
        originalDistributionForecast = zeros(Float64, obserSpaceOriginal.dimension)
        for indexTimestamp in keys(timestampsDistributionForecast)
            originalDistributionForecast[mappingTimestampToOriginalIndeces[indexTimestamp]] += timestampsDistributionForecast[indexTimestamp]
        end
        push!(originalDistributionForecastVector, originalDistributionForecast)
    end
    return originalDistributionForecastVector
end

#-------------------------------------------------------------------------
# Test data
function loadObservations1(path::String)
    # Öffnen einer Excel-Datei
    xf = XLSX.readxlsx(path)
    sh = xf["UserCustom"] 
    data = sh["B3:B100"] |> vec
        
    return(data)
end

function loadObservations2(path::String)
    # Öffnen einer Excel-Datei
    xf = XLSX.readxlsx(path)
    sh = xf["sers"] 
    data = sh["B1:B5000"] |> vec
        
    return(data)
end

function getTestDataDay()
    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/PV_2024_09_22.xlsx"
    observations = loadObservations1(path)

    # Convert Data
    discreteObser = discretize(observations)
    observationSpace = Set(discreteObser) |> ObservationSpace
    observationsAsIndeces = translateObservationsToIndex(discreteObser, observationSpace)

    return(observationSpace, observationsAsIndeces)
end

function getTestData2Month()
    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/verbrauch_schimek_okt_nov.xlsx"
    observations = loadObservations2(path)

    # Convert Data
    discreteObser = discretize(observations)
    observationSpace = Set(discreteObser) |> ObservationSpace
    observationsAsIndeces = translateObservationsToIndex(discreteObser, observationSpace)

    return(observationSpace, observationsAsIndeces)
end