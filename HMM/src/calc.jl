module Calc 

using Main.HMM.Types
using Main.HMM.Helpers

export forwardAlgo, BaumWelchAlgo

function forwardAlgo(T, hmm::HMM, observations::Vector{Int})
    observationsAsIndeces = translateObservationsToIndex(observations, hmm.observationSpace)
    alpha = zeros(T, hmm.numberOfStateSpace)

    println(observationsAsIndeces)
    # Init
    for i in 1:hmm.numberOfStateSpace
        alpha[1,i] = hmm.startingDistribution.probabilities[i]*hmm.observationMatrix.transitionMatrix[i,observationsAsIndeces[1]]
    end

    # Calc
    for t in 2:T
        for i in 1:hmm.numberOfStateSpace
            alpha[t,i] = sum(forwardCalc, (alpha[t-1,:], hmm.transitionMatrix.transitionMatrix[:,i], hmm.observationMatrix.transitionMatrix[:,observationsAsIndeces[t]]) )
        end 
    end

    # Terminate
    liklihood = sum(alpha[T,:])

    return (alpha, liklihood)
end

function BaumWelchAlgo(Z, V, N::Int)
    # Init
    transMatrixA = ones(N,N) ./ N
    a = A(N, transMatrixA)

    M = length(V.observations)
    transMatrixB =  ones(N,M) ./ M
    b = B((N,M), transMatrixB)

    pi = transMatrixA[1,:] |> StochasticVector
    T = length(Z)

    hmm_init = HMM(N, a, b, pi, V)
    # Expecatation 
    results = forwardAlgo(T, hmm_init, Z)

    # Maximization

    # Terminate

    # Return Value
    return HMM(N,a,b,pi,V)
end
end

