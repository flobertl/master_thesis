module Helpers

using Main.HMM.Types
using Distributions, Random
using HiddenMarkovModels: HMM as HMMPkg 

export translateObservationsToIndex, translateIndexToObservations, forwardCalc, backwardCalc, createRandomTransitionMatrixViaDirichlet
export createRandomHMM, transformDistributionVectorToFrequencyVector

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
    observations = zeros(Int64, T)
    for t in 1:T
        observations[t] = observationSpace.mapIndexToObservation[observationsAsIndex[t]]
    end
    return observations
end

function forwardCalc(alpha_tminus1::Array{Float32, 1}, a_point_i::Array{Float32, 1}, b_point_o_t::Float32)
    alpha_tminus1 .* a_point_i .* b_point_o_t
end

function backwardCalc(beta_tplus1::Array{Float32, 1}, a_i_point::Array{Float32, 1}, b_point_o_t::Array{Float32, 1})
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

function transformHMMToPkgHMM(hmm::HMM)
    A_ = hmm.transitionMatrix.transitionMatrix
    b_ = hmm.observationMatrix.transitionMatrix
    initDistr = hmm.startingDistribution.probabilities
    (N, M) = hmm.observationMatrix.dimension

    B_ = Array{Categorical}(undef, N)
    for j in 1:N
        B_[j] = b_[j, :] |> Categorical
    end
    HMMPkg(initDistr, A_, B_)
end

function transformDistributionVectorToFrequencyVector(observationSpace::ObservationSpace, distribution::Vector{Float32})::Vector{Int}
    numberOfFrequencies = map(round, distribution .* 1000)
    index = collect(1:observationSpace.dimension)
    observationVector = translateIndexToObservations(index, observationSpace)
    frequencyObs = []
    for i in index
        frequencyObs_i = [observationVector[i] for t in 1:numberOfFrequencies[i]]
        append!(frequencyObs, frequencyObs_i)
    end

    return frequencyObs
end


end