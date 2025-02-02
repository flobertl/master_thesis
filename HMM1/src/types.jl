module Types

export Probability, A, B, HMM, StochasticVector, ObservationSpace

struct Probability
    value::Float32

    function Probability(value::Float32)
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
    transitionMatrix::Array{Float32, 2}
    
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
    dimension::Tuple{Int,Int}
    transitionMatrix::Array{Float32, 2}

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
    dimension::Int
    observations::Set{Int}
    mapObservationToIndex::Dict{Int, Int}
    mapIndexToObservation::Dict{Int, Int}

    function ObservationSpace(observations::Set{Int})
        sortedObservations = observations |> collect |> sort
        mapObservationToIndex = Dict()
        mapIndexToObservation = Dict()
        dim = length(sortedObservations)
        for i in 1:dim 
            mapObservationToIndex[sortedObservations[i]] = i
        end
        mapIndexToObservation = Dict()
        for i in 1:(length(sortedObservations)) 
            mapIndexToObservation[i] = sortedObservations[i]
        end
        new(dim, observations, mapObservationToIndex, mapIndexToObservation)
    end
    function ObservationSpace(dim::Int, observations::Set{Int}, mapObserToIndex::Dict{Int, Int}, mapIndexToObser::Dict{Int, Int})
        new(dim, observations, mapObserToIndex, mapIndexToObser)
    end
end

struct StochasticVector
    probabilities::Vector{Float32}
end


struct HMM 
    numberOfStateSpace::Int
    transitionMatrix::A
    observationMatrix::B
    startingDistribution::StochasticVector
    observationSpace::ObservationSpace
end

function Base.:(==)(x::HMM, y::HMM)
    a = all(x.transitionMatrix.transitionMatrix .== y.transitionMatrix.transitionMatrix)
    b = all(x.observationMatrix.transitionMatrix .== y.observationMatrix.transitionMatrix)
    p = all(x.startingDistribution.probabilities .== y.startingDistribution.probabilities)
    return (a && b && p)
end

end

