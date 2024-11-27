module Types

export Probability, A, B, HMM, StochasticVector, ObservationSpace

struct Probability
    value::Float64

    function Probability(value::Float64)
        # Überprüfe, ob die Matrix quadratisch ist
        if (value < 0.) || (value > 1.)
            error("Probability $value not in [0,1].")
        end
        # Erzeuge das Objekt
        new(value)
    end
end

struct A
    dimension::UInt
    transitionMatrix::Array{Float64, 2}
    
    function A(dim, transMatrix)
        a,b = size(transMatrix)
        if (a != dim) || (b != dim)
            error("Matrix A not of dim $dim")
        end
        # Check for Wahrscheinlichkeitsmatrix sumOfRows = sum(A, dims=2) 
        # Erzeuge das Objekt
        new(dim, transMatrix)
    end
end

struct B
    dimensions::Tuple{Int,Int}
    transitionMatrix::Array{Float64, 2}

    function B((dim1, dim2), transMatrix)
        a,b = size(transMatrix)
        if (a != dim1) || (b != dim2)
            error("Matrix B not of dim $dim1*$dim2")
        end
        # Erzeuge das Objekt
        new((dim1, dim2), transMatrix)
    end
end


struct ObservationSpace
    observations::Set{Int}
    mapObservationToIndex::Dict{Int, Int}
    mapIndexToObservation::Dict{Int, Int}

    function ObservationSpace(observations::Set{Int})
        sortedObservations = observations |> collect |> sort
        mapObservationToIndex = Dict()
        mapIndexToObservation = Dict()
        for i in 1:(length(sortedObservations)) 
            mapObservationToIndex[sortedObservations[i]] = i
        end

        mapIndexToObservation = Dict()
        for i in 1:(length(sortedObservations)) 
            mapIndexToObservation[i] = sortedObservations[i]
        end

        new(observations, mapObservationToIndex, mapIndexToObservation)
    end
end

struct StochasticVector
    probabilities::Vector{Float64}
end


struct HMM 
    numberOfStateSpace::Int
    transitionMatrix::A
    observationMatrix::B
    startingDistribution::StochasticVector
    observationSpace::ObservationSpace
end
end