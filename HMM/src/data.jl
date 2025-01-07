module Data

using Main.HMM.Types, Main.HMM.Helpers
using XLSX, DataFrames

export loadObservations2, loadObservations1 , discretize, getTestData2Month, getTestDataDay, saveHMM, loadHMM

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


function discretize(observations)
    discreteObs = map(round, observations)
    return map(Int, discreteObs)
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

function getData2Years(householdId::Int64)
    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/15households_2years.xlsx"
    df = DataFrame(XLSX.readtable(path, "Sheet1"))

    observations = df[:, string(householdId)]

    # Convert Data
    discreteObser = discretize(observations)
    observationSpace = Set(discreteObser) |> ObservationSpace
    observationsAsIndeces = translateObservationsToIndex(discreteObser, observationSpace)

    return(observationSpace, observationsAsIndeces)
end



function saveHMM(hmm::HMM, fileName::String)
    # path of directory
    folderPath = ".//tmp//"
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

# Function to load the HMM struct from a file
function loadHMM(fileName::String)
    # path of directory
    folderPath = ".//tmp//"
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

end
