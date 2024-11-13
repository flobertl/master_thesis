module Calc 

using Main.HMM.Types, Main.HMM.Helpers

export forwardAlgo, BaumWelchAlgo

function forwardAlgo(T, hmm::HMM, observations::Vector{Int})
    observationsAsIndeces = translateObservationsToIndex(observations, hmm.observationSpace)

    # Init
    alpha = zeros(T, hmm.numberOfStateSpace)
    for i in 1:hmm.numberOfStateSpace
        alpha[1,i] = hmm.startingDistribution.probabilities[i]*hmm.observationMatrix.transitionMatrix[i,observationsAsIndeces[1]]
    end

    # Calc
    for t in 2:T
        for i in 1:hmm.numberOfStateSpace
            zwischenresultat = forwardCalc(alpha[t-1,:], hmm.transitionMatrix.transitionMatrix[:,i], hmm.observationMatrix.transitionMatrix[:,observationsAsIndeces[t]])
            alpha[t,i] = sum(zwischenresultat)
        end 
    end

    # Terminate
    likelihood = sum(alpha[T,:])

    return (alpha, likelihood)
end

function backwardAlgo(T, hmm::HMM, observations::Vector{Int})
    observationsAsIndeces = translateObservationsToIndex(observations, hmm.observationSpace)

    #Init - 
    beta = ones(T, hmm.numberOfStateSpace)
    #= wird von alokaliesierung übernommen
    for i in 1:hmm.numberOfStateSpace
        beta[T,i] = 1
    end
    =#

    # Calc
    for t in T-1:-1:1
        for i in 1:hmm.numberOfStateSpace
            summenTerme = backwardCalc(beta[t+1,:], hmm.transitionMatrix.transitionMatrix[i,:], hmm.observationMatrix.transitionMatrix[:,observationsAsIndeces[t+1]])
            beta[t,i] = sum(summenTerme)
        end 
    end

    # Terminate
    likelihood = backwardCalc(beta[1,:], hmm.startingDistribution.probabilities[:], hmm.observationMatrix.transitionMatrix[:,observationsAsIndeces[1]]) |> sum

    return (beta, likelihood)
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
    (alpha, likelihood1) = forwardAlgo(T, hmm_init, Z)
    (beta, likelihood2) = backwardAlgo(T, hmm_init, Z)

    # Maximization

    # Terminate

    # Return Value
    return HMM(N,a,b,pi,V)
end

end