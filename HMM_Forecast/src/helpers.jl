using Distributions, Random, LinearAlgebra
using HiddenMarkovModels: HMM as HMMPkg 

function isNumericalEqual(leftSide, rightSide)::Bool
    epsilon = 1E-10
    (rightSide - epsilon < leftSide) && (leftSide < rightSide + epsilon)
end

function translateObservationsToIndex(observations::Vector{Int}, observationSpace::ObservationSpace)
    f(x) = observationSpace.mapObservationToIndex[x]
    observationsAsIndex = map(f, observations)
    return observationsAsIndex
end

function translateIndexToObservations(observationsAsIndex::Array{Int, 1}, observationSpace::ObservationSpace)
    f(x) = observationSpace.mapIndexToObservation[x]
    observations = map(f, observationsAsIndex)
    return observations
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

function transformDistributionVectorToFrequencyVector(observationSpace::ObservationSpace, distribution::Vector{Float64})::Vector{Int}
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

function printTimeAndResetTimeStamp(prevTime)
    println(" ### Timing: {$((now() - prevTime).value/1000)}sec ### ")
    newTime = now()
    return newTime
end

function updateHMMNumericalStable(hmm::HMM)
    obsMatrix_numStable = hmm.observationMatrix.transitionMatrix .+ 10e-15 
    newObservationMatrix = B(hmm.observationMatrix.dimension, obsMatrix_numStable./ sum(obsMatrix_numStable, dims = 2))
    HMM(hmm.numberOfStateSpace, hmm.transitionMatrix, newObservationMatrix, hmm.startingDistribution, hmm.observationSpace)
end

function updateHMMWithStationaryInitDistro(oldHMM::HMM)::HMM
    eigenvalues, eigenvectors = eigen(oldHMM.transitionMatrix.transitionMatrix')
    indicesForEigenvector = findall(x -> isNumericalEqual(x, 1), eigenvalues) 
    println(oldHMM.transitionMatrix.transitionMatrix, eigenvalues, eigenvectors)

    if isempty(indicesForEigenvector)
        throw(DomainError((eigenvalues, eigenvectors), "There is no eigenvalue = 1. (=> No stationary distribution)"))
    elseif length(indicesForEigenvector) == 1
        #println(eigenvectors[indicesForEigenvector[1], :])
        singleEigenVector = eigenvectors[:, indicesForEigenvector[1]] / sum(eigenvectors[:, indicesForEigenvector[1]])
        #println(singleEigenVector)
    else 
        throw(DomainError((eigenvalues, eigenvectors), "There are multiple eigenvalues = 1. (=> Multiple stationary distribution)"))
    end

    if singleEigenVector isa Array{Float64}
        stationaryDistro = StochasticVector(singleEigenVector)
    else
        throw(DonainError(singleEigenVector, "The eigenvector is of type $(typeof(singleEigenVector))"))
    end

    newHMM = HMM(oldHMM.numberOfStateSpace, oldHMM.transitionMatrix, oldHMM.observationMatrix, stationaryDistro, oldHMM.observationSpace)
    
    return newHMM
end