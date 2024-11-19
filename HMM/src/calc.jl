module Calc 

using Main.HMM.Types, Main.HMM.Helpers

export forwardAlgo, backwardAlgo, BaumWelchAlgo

function forwardAlgo(T, hmm::HMM, observations::Vector{Int})
    # Init
    alpha = zeros(T, hmm.numberOfStateSpace)
    for i in 1:hmm.numberOfStateSpace
        alpha[1,i] = hmm.startingDistribution.probabilities[i]*hmm.observationMatrix.transitionMatrix[i,observations[1]]
    end

    # Calc
    for t in 2:T
        for i in 1:hmm.numberOfStateSpace
            zwischenresultat = forwardCalc(alpha[t-1,:], hmm.transitionMatrix.transitionMatrix[:,i], hmm.observationMatrix.transitionMatrix[:,observations[t]])
            alpha[t,i] = sum(zwischenresultat)
        end 
    end

    # Terminate
    likelihood = sum(alpha[T,:])

    return (alpha, likelihood)
end

function backwardAlgo(T, hmm::HMM, observations::Vector{Int})
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
            summenTerme = backwardCalc(beta[t+1,:], hmm.transitionMatrix.transitionMatrix[i,:], hmm.observationMatrix.transitionMatrix[:,observations[t+1]])
            beta[t,i] = sum(summenTerme)
        end 
    end

    # Terminate
    likelihood = backwardCalc(beta[1,:], hmm.startingDistribution.probabilities[:], hmm.observationMatrix.transitionMatrix[:,observations[1]]) |> sum

    return (beta, likelihood)
end

function BaumWelchAlgo(observations, observationSpace, N::Int)
    # parameter für Abbruchbedingung
    convergenceKoeff = 1E-18

    # Init
    pi = [1; zeros(N-1)] |> StochasticVector
    
    T = length(observations)

    M = length(observationSpace.observations)

    # Init
    Random.seed!(1234)
    transMatrixA_hat = createRandomTransitionMatrixViaDirichlet(N,N)
    transMatrixB_hat =  createRandomTransitionMatrixViaDirichlet(N,M)
    a = A(N, transMatrixA_hat)
    b = B((N,M), transMatrixB_hat)
    hmm = HMM(N, a, b, pi, observationSpace)

    likelihood_old = 0
    likelihood_next = 1

    # Init values for tracking iteration and time
    iter = 1
    time_prev = time()

    for x in 1:1000
        # Expecatation 
        (alpha, likelihood_next) = forwardAlgo(T, hmm, observations)
        (beta, likelihood2) = backwardAlgo(T, hmm, observations)

        gamma = zeros(T-1, N, N)
        transMatrixA_hat = zeros(N,N)
        transMatrixB_hat = zeros(N,M)

        # Calculation of gamma
        for t in 1:(T-1)
            for i in 1:N 
                for j in 1:N 
                    gamma[t,i,j] = alpha[t,i] * a.transitionMatrix[i,j] * b.transitionMatrix[j, observations[t+1]] * beta[t+1,j]
                end
            end
        end

        # Calculation of A_hat
        for i in 1:N
            summe = sum(gamma[:,i,:])
            if (summe != 0)
                for j in 1:N
                    transMatrixA_hat[i,j] = sum(gamma[:,i,j]) / summe
                end
            end
        end

        # Calculation of B_hat
        for l in 1:M
            accurances = findall(obs -> obs == l, observations[1:end-1])
            for i in 1:N
                summe = sum(gamma[:,i,:])
                if (summe != 0)
                   transMatrixB_hat[i,l] = sum(gamma[accurances,i,:])/summe
                end
            end
        end

        a = A(N, transMatrixA_hat)
        b = B((N,M), transMatrixB_hat)
        hmm = HMM(N, a, b, pi, observationSpace)

        # Tracking iteration and timing
        now = time()
        println("BW-Algo: ", iter, ".iteration taking ", (now - time_prev), " Liklihood: ",likelihood_next)
        time_prev = now
        iter += 1
    end
    # Maximization

    # Terminate


    # Return Value
    return HMM(N,a,b,pi,observationSpace)
end

end