module Helpers

using Main.HMM.Types
using Distributions, Random

export translateObservationsToIndex, translateIndexToObservations, forwardCalc, backwardCalc, createRandomTransitionMatrixViaDirichlet
export createRandomHMM

function translateObservationsToIndex(observations::Vector{Int}, observationSpace::ObservationSpace)
    T = length(observations)
    observationsAsIndex = zeros(Int, T)
    for t in 1:T
        observationsAsIndex[t] = observationSpace.mapObservationToIndex[observations[t]]
    end
    return observationsAsIndex
end

function translateIndexToObservations(observationsAsIndex::Array{Int, 1}, observationSpace::ObservationSpace)
    T = length(observationsAsIndex)
    observations = zeros(T)
    for t in 1:T
        observations[t] = observationSpace.mapIndexToObservation[observationsAsIndex[t]]
    end
    return observations
end

function forwardCalc(alpha_tminus1::Array{Float64, 1}, a_point_i::Array{Float64, 1}, b_point_o_t::Float64)
    alpha_tminus1 .* a_point_i .* b_point_o_t
end

function backwardCalc(beta_tplus1::Array{Float64, 1}, a_i_point::Array{Float64, 1}, b_point_o_t::Array{Float64, 1})
    beta_tplus1 .* a_i_point .* b_point_o_t
end


function randomDirichletVector(n::Int)
    d = Dirichlet(fill(1.0, n))  # Dirichlet-Verteilung mit α=1 für jedes Element
    return rand(d)               # Ziehe einen zufälligen Vektor
end

function createRandomTransitionMatrixViaDirichlet(n::Int, m::Int)
    transMatrix = zeros(n,m)
    for i in 1:n
        transMatrix[i,:] = randomDirichletVector(m)
    end
    return transMatrix
end

function createRandomHMM(dimHiddenStateSpace::Int, observationSpace::ObservationSpace)
    N = dimHiddenStateSpace
    M = observationSpace.dimension
    Random.seed!(123)
    pi = [1; zeros(N-1)] |> StochasticVector
    transMatrixA_hat = createRandomTransitionMatrixViaDirichlet(N,N)
    transMatrixB_hat =  createRandomTransitionMatrixViaDirichlet(N,M)
    a = A(N, transMatrixA_hat)
    b = B((N,M), transMatrixB_hat)
    hmm = HMM(N, a, b, pi, observationSpace)

    return hmm
end

end