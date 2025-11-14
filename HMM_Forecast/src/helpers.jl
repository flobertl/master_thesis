using Distributions, Random, LinearAlgebra, QuantEcon
using HiddenMarkovModels: HMM as HMMPkg 

# Given data and the indeces, it generates the regressor matrix x
# The explainotry variables are the data of the 2 last days, the value exactly 1 week and 2 weeks ago, daytime and month (as sin/cos cyclically encoded)
function translateDataToQRMatrixX(data, dateIndeces, historicWindowLength)
    function datetime_transformation(index)
        dateTime = dateTimesOf2YearsData()[dateIndeces[index]]
        dayTime_Scaled = (Dates.hour(dateTime) + Dates.minute(dateTime)/60) * (2*pi/24)
        month_Scaled = Dates.month(dateTime) * (2*pi/12)

        return [sin(dayTime_Scaled), cos(dayTime_Scaled), sin(month_Scaled), cos(month_Scaled)]
    end

    X = zeros(Float32, length(data), historicWindowLength+6)
    for i in 1:length(data)
        x_past2Days = [ if (index < 1) NaN else data[index] end for index in (i-historicWindowLength):(i-1)]
        x_shiftedvalues = [if (index < 1) NaN else data[index] end for index in [i-96*7, i-96*14]]
        x_daytime_month =  datetime_transformation(i)
        x = vcat(x_past2Days, x_shiftedvalues, x_daytime_month)
        X[i, :] = x
    end
    return X
end 

function isNumericalEqual(leftSide, rightSide)::Bool
    epsilon = 1E-10
    (rightSide - epsilon < leftSide) && (leftSide < rightSide + epsilon)
end

function translateObservationsToIndex(observations::Vector{Float32}, observationSpace::ObservationSpace)
    f(x) = observationSpace.mapObservationToIndex[x]
    observationsAsIndex = map(f, observations)
    return observationsAsIndex
end

function translateIndexToObservations(observationsAsIndex::Array{Int, 1}, observationSpace::ObservationSpace)
    f(x) = observationSpace.mapIndexToObservation[x]
    observations = map(f, observationsAsIndex)
    return observations
end

# Alte  funktion zum mappen von Int-obsevationen in legacy code
function translateObservationsAsIntToIndex(observations::Vector{Int}, observationSpace::ObservationSpace)
    f(x) = observationSpace.mapObservationToIndex[x]
    observationsAsIndex = map(f, observations)
    return observationsAsIndex
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

function transformDistributionVectorToFrequencyVector(observationSpace::ObservationSpace, distribution::Vector{Float64})::Vector{Float32}
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

function printTimeAndResetTimeStamp(prevTime, prefix = "")
    println(" ### $prefix Timing: {$((now() - prevTime).value/1000)}sec ### ")
    newTime = now()
    return newTime
end
# Adding an epsilon probability to each entry of the observationMatrix
# Avoids numerical total zeros
function updateHMMNumericalStable(hmm::HMM)
    obsMatrix_numStable = hmm.observationMatrix.transitionMatrix .+ 10e-15 
    newObservationMatrix = B(hmm.observationMatrix.dimension, obsMatrix_numStable./ sum(obsMatrix_numStable, dims = 2))
    HMM(hmm.numberOfStateSpace, hmm.transitionMatrix, newObservationMatrix, hmm.startingDistribution, hmm.observationSpace)
end

function calcStationaryDistribution(hmm::HMM)::Vector{Float64}
    P = hmm.transitionMatrix.transitionMatrix;
    mc = MarkovChain(P);
    stationaryDistro = stationary_distributions(mc)[1]
    return stationaryDistro
end

function updateHMMWithStationaryInitDistro(oldHMM::HMM)::HMM

    stationaryDistro = calcsStationaryDistribution(oldHMM) |> StochasticVector
    newHMM = HMM(oldHMM.numberOfStateSpace, oldHMM.transitionMatrix, oldHMM.observationMatrix, stationaryDistro, oldHMM.observationSpace)
    # eigenvalues, eigenvectors = eigen(oldHMM.transitionMatrix.transitionMatrix')
    # indicesForEigenvector = findall(x -> isNumericalEqual(x, 1), map(real, filter(isreal, eigenvalues))) 
    # println("6.Reihe:")
    # println(eigenvectors[6, :])
    # println("6.Spalte:")
    # println(eigenvectors[:, 6])
    # if isempty(indicesForEigenvector)
    #     throw(DomainError((eigenvalues, eigenvectors), "There is no eigenvalue = 1. (=> No stationary distribution)"))
    # elseif length(indicesForEigenvector) == 1
    #     println(eigenvectors[:, indicesForEigenvector[1]])
    #     singleEigenVector_real = eigenvectors[:, indicesForEigenvector[1]] |> real
    #     singleEigenVector = singleEigenVector_real/ sum(singleEigenVector_real)
    #     println(singleEigenVector)
    # else 
    #     throw(DomainError((eigenvalues, eigenvectors), "There are multiple eigenvalues = 1. (=> Multiple stationary distribution)"))
    # end

    # if singleEigenVector isa Array{Float64}
    #     stationaryDistro = StochasticVector(singleEigenVector)
    # else
    #     #println(singleEigenVector)
    #     throw(DomainError(singleEigenVector, "The eigenvector is of type $(typeof(singleEigenVector))"))
    # end

    # newHMM = HMM(oldHMM.numberOfStateSpace, oldHMM.transitionMatrix, oldHMM.observationMatrix, stationaryDistro, oldHMM.observationSpace)
    
    # throw(DomainError(999999999999999, "The eigenvector is of type $(typeof(singleEigenVector))"))

    return newHMM
end