using XLSX, DataFrames, Dates, CSV, Statistics, Base


# ------------------------------------------------------------------------------
# Preprocessing for HMM 
# Discretizes Observations and generates coresponding HMM observation Space
function preprocessing(originalObservations::Vector{Float32}, discretTyp::String, numberOfObservations::Int)
    # Discretization
    if discretTyp == "A"
        observations, infoBins = discretizeEqualMassBins(numberOfObservations, originalObservations)
    elseif discretTyp == "B"
        observations, infoBins = discretizeEqualSizeBins(numberOfObservations, originalObservations)
    else
        error("No valid discretization type (A/B).")
    end
    observationSpace = Set(observations) |> ObservationSpace
    observationsAsIndeces = translateObservationsToIndex(observations, observationSpace)
    return((observationSpace, infoBins), observations, observationsAsIndeces)
end

# ---------------------------------------------------------------------------
# Productive Load Function

function loadOriginalData(hh::Int)::Vector{Float32}
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/15households_2years.xlsx"
    df = DataFrame(XLSX.readtable(path, "Sheet1"))
    originalObservations = df[:, string(hh)]
    return originalObservations
end

# Ladet und normalisiert aus Datentabelle die Zeitreihe des entsprechenden Haushalts (hh)
function readAndNormalizeData(hh::Int)::Vector{Float32}
    # Load Data
    originalObservations = loadOriginalData(hh)
    # Convert Data
    observations = originalObservations |> normalizeWithMaxElement
    return(observations)
end

#----------------------------------------------------------------------------
# Discretizer

function discretizeEqualMassBins(numberBins::Int, observations::Vector{Float32})
    quantiles = [(1/numberBins)* quant for quant in 1:numberBins]
    empiricQuantiles = quantile(observations, quantiles, sorted=false)

    observationsDiscretized = Vector{Float32}(undef, length(observations))
    corresponingBins = [searchsortedfirst(empiricQuantiles, obs) for obs in observations]
    nodes = vcat(0, empiricQuantiles)
    infoBins = []
    for bin in 1:numberBins
        indecesBin = corresponingBins .== bin
        binMedian = median(observations[indecesBin])
        observationsDiscretized[indecesBin] .= binMedian
        infoBin = (nodes[bin], nodes[bin+1]-nodes[bin]) # Tuple (first "stuetzstelle", length of bin)
        push!(infoBins, infoBin)
    end

    if (length(Set(observationsDiscretized)) != numberBins)
        error("Diskretisierung fehlgeschlagen! Anzahl der Bins nicht erfuellt.")
    end
    return observationsDiscretized, infoBins
end

function discretizeEqualSizeBins(numberBins::Int, observations::Vector{Float32})
    nodes = [(1/numberBins)* quant for quant in 1:numberBins]

    observationsDiscretized = Vector{Float32}(undef, length(observations))
    corresponingBins = [searchsortedfirst(nodes, obs) for obs in observations]
    nodes = vcat(0, nodes)
    infoBins = []   
    for bin in 1:numberBins
        indecesBin = corresponingBins .== bin
        binMean = Statistics.mean(observations[indecesBin])
        observationsDiscretized[indecesBin] .= binMean
        if any(indecesBin)          #Check for non-empty bin
            infoBin = (nodes[bin], nodes[bin+1]-nodes[bin]) # Tuple (first "stuetzstelle", length of bin)
            push!(infoBins, infoBin)
        end
    end
    if length(infoBins) != length(unique(observationsDiscretized))
        throw(DomainError("Info of bins not in accordance with the total number of bins."))
    end

    return observationsDiscretized, infoBins
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
        observations = parse.(Float32, split(readline(io), ",")) |> Set
        pairs = split(readline(io), ",")
        # Process each pair and convert to key-value format
        key_value_pairs = [split(pair, ":") for pair in pairs]
        mapObserToIndex = Dict(parse(Float32, kv[1]) => parse(Int, kv[2]) for kv in key_value_pairs)
        mapIndexToObser = Dict(parse(Int, kv[2]) => parse(Float32, kv[1]) for kv in key_value_pairs)
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
# Save and load data tables
tmpPath = ".//HMM_Forecast//tmp//"

function saveCSVTable(title::String, table, variableA, variableB)
    rows = []

    for (i, a) in enumerate(variableA)
        for (j, b) in enumerate(variableB)
            push!(rows, (VarA = a, VarB = b, Value = table[i, j]))
        end
    end
    df = DataFrame(rows)
    CSV.write(tmpPath*title*".csv", df)
end

function loadCSVTable(title::String)
    df = CSV.read(tmpPath*title*".csv", DataFrame)

    # Eindeutige Zustände (x-Achse) und Fenstergrößen (für Linien)
    variablesA  = sort(unique(df.VarA))
    variablesB = sort(unique(df.VarB))

    # MAE-Matrix initialisieren
    table = Array{Float64, 2}(undef, length(variablesA), length(variablesB))

    # Füllen der Matrix
    for row in eachrow(df)
        i = findfirst(==(row.VarA), variablesA)
        j = findfirst(==(row.VarB), variablesB)
        if (i !== nothing) & (j !== nothing)
            table[i, j] = row.Value
        end
    end

    return table, variablesA, variablesB
end

function saveLinQRTrainingsMatrix(hh, (intercept, coefficients))
    title = "benchmark//LinQRTrainingsMatrix_hh($hh)"
    quantiles = 0.01:0.01:0.99
    coef_description = vcat("intercept", 1:198)
    matrix = hcat(intercept, coefficients)
    saveCSVTable(title, matrix, quantiles, coef_description)
end

function loadLinQRTrainingsMatrix(hh)
    title = "benchmark//LinQRTrainingsMatrix_hh($hh)"
    matrix, x, y = loadCSVTable(title)
    intercept = matrix[:, 1]
    coefficients = matrix[:,2:end]
    return intercept, coefficients
end



function saveResultsTable(title::String, table, observationsVector, statesVector)
    rows = []

    for (i, observations) in enumerate(observationsVector)
        for (j, states) in enumerate(statesVector)
            push!(rows, (Observations = observations, States = states, LogLikeTest = table[i, j][1][1], LogLikeTrain = table[i, j][1][2], CRPS = table[i, j][2]))
        end
    end
    df = DataFrame(rows)
    CSV.write(tmpPath*title*".csv", df)
end

function loadResultsTable(title::String, observationsVector, statesVector)
    df = CSV.read(tmpPath*title*".csv", DataFrame)
    subdf = filter(row -> row.Observations in observationsVector && row.States in statesVector, df) #gnerates subdf
    lookup = Dict((row.Observations, row.States) => ((row.LogLikeTest, row.LogLikeTrain), row.CRPS) for row in eachrow(subdf)) # transforms into dictionary

    # MAE-Matrix initialisieren
    table = Array{Tuple{Tuple{Float64, Float64}, Float64}}(undef, length(observationsVector), length(statesVector))

    for (i, observation) in enumerate(observationsVector)
        for (j, state) in enumerate(statesVector)
            table[i, j] = get(lookup, (observation, state), ((NaN, NaN),NaN))
        end
    end
    return table
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
    observationsAsIndeces = translateObservationsAsIntToIndex(discreteObser, observationSpace)

    return(observationSpace, observationsAsIndeces)
end

function getTestData2Month()
    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/verbrauch_schimek_okt_nov.xlsx"
    observations = loadObservations2(path)

    # Convert Data
    discreteObser = discretize(observations)
    observationSpace = Set(discreteObser) |> ObservationSpace
    observationsAsIndeces = translateObservationsAsIntToIndex(discreteObser, observationSpace)

    return(observationSpace, observationsAsIndeces)
end

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

function normalizeWithMaxElement(observations::Vector{})::Vector{Float32}
    maxElement = maximum(observations)
    normalizedObservations = map(Float32, observations./maxElement)
    return normalizedObservations
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

#-------------------------------------------------------------
## legacy Code

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

function getData2YearsOriginal(householdId::Int64)
    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/15households_2years.xlsx"
    df = DataFrame(XLSX.readtable(path, "Sheet1"))
    observations = df[:, string(householdId)]

    # Convert Data
    originalObser = observations |> discretize
    return(originalObser)
end

function getData2Years(householdId::Int64)
    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/15households_2years.xlsx"
    df = DataFrame(XLSX.readtable(path, "Sheet1"))
    observations = df[:, string(householdId)]

    # Convert Data
    abstractObser = observations |> discretize |> abstractLoadObservations
    observationSpace = Set(abstractObser) |> ObservationSpace
    observationsAsIndeces = translateObservationsAsIntToIndex(abstractObser, observationSpace)

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
    observationsAsIndeces = translateObservationsAsIntToIndex(abstractObserWithTimestamps, observationSpace)

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
    observationsAsIndeces = translateObservationsAsIntToIndex(abstractObser, observationSpace)

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
    observationsAsIndeces = translateObservationsAsIntToIndex(abstractObserWithTimestamps, observationSpace)

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
    observationsAsIndeces = translateObservationsAsIntToIndex(abstractObserWithTimestamps, observationSpace)

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
    observationsAsIndeces = translateObservationsAsIntToIndex(abstractObserWithTimestamps, observationSpace)

    return(observationSpace, abstractObserWithTimestamps, observationsAsIndeces)
end