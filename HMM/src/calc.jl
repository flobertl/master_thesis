module Calc 

using Main.HMM.Types, Main.HMM.Helpers, Random

export forwardAlgo, backwardAlgo, baumWelchAlgo, bestPathPrognosis

function forwardAlgo(hmm::HMM, observations::Vector{Int})
    T = length(observations)
    # Init
    alpha = zeros(T, hmm.numberOfStateSpace)
    for i in 1:hmm.numberOfStateSpace
        alpha[1,i] = hmm.startingDistribution.probabilities[i]*hmm.observationMatrix.transitionMatrix[i,observations[1]]
    end

    # Calc
    for t in 2:T
        for i in 1:hmm.numberOfStateSpace
            zwischenresultat = forwardCalc(alpha[t-1,:], hmm.transitionMatrix.transitionMatrix[:,i], hmm.observationMatrix.transitionMatrix[i, observations[t]])
            alpha[t,i] = sum(zwischenresultat)
        end 
        #alpha[t,:] = alpha[t,:] ./ sum(alpha[t,:])
    end

    # Terminate
    likelihood = sum(alpha[T,:])

    return (alpha, likelihood)
end

function backwardAlgo(hmm::HMM, observations::Vector{Int})
    T = length(observations)
    #Init - 
    beta = ones(T, hmm.numberOfStateSpace)

    # Calc
    for t in T-1:-1:1
        for i in 1:hmm.numberOfStateSpace
            summenTerme = backwardCalc(beta[t+1,:], hmm.transitionMatrix.transitionMatrix[i,:], hmm.observationMatrix.transitionMatrix[i,observations[t]])
            beta[t,i] = sum(summenTerme)
        end 
        #beta[t,:] = beta[t,:] ./ sum(beta[t,:])
    end

    # Terminate
    likelihood = backwardCalc(beta[1,:], hmm.startingDistribution.probabilities[:], hmm.observationMatrix.transitionMatrix[:,observations[1]]) |> sum

    return (beta, likelihood)
end

function baumWelchAlgo(observations, observationSpace, N::Int)
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

    likelihood_prev_prev = 0
    likelihood_prev = 0
    likelihood_next = nextfloat(0.0)

    # Init values for tracking iteration and time
    iter = 1
    time_prev = time()

    alpha = zeros(T, N)

    for x in 1:10
        # Expecatation 
        (alpha, likelihood_next) = forwardAlgo(hmm, observations)
        (beta, likelihood2) = backwardAlgo(hmm, observations)

        # Termination Condition
        if (likelihood_next < likelihood_prev) && (likelihood_prev < likelihood_prev_prev) 
            break
        end
        likelihood_prev_prev = likelihood_prev
        likelihood_prev = likelihood_next

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
    # Return Value
    return HMM(N,a,b,pi,observationSpace), alpha
end

function bestPathPrognosis(hmm::HMM, observations, forecastHorizon::Int)
    # Set parameter
    T = length(observations)
    N, M = hmm.observationMatrix.dimensions  # N = #hiddenStates, B = #observationStates
    
    # Step 0: Calc alpha(T)
    alpha_T = forwardAlgo(hmm, observations)[1][T,:]

    # Init Step: Alocate alpha_i^k(T+1), Z_hat
    alpha_i_k = zeros(N, M)
    Z_hat = zeros(Int, forecastHorizon)
    alpha_prev = alpha_T

    # Rec Step:
    for t in 1:forecastHorizon 
        # Calc alpha_i_k
        for i in 1:N
            for k in 1:M
                alpha_i_k[i, k] = sum(alpha_prev .* hmm.transitionMatrix.transitionMatrix[:,i]) * hmm.observationMatrix.transitionMatrix[i, k]
            end
        end
        # Select the most likely observation state as path prognosis
        alpha_i_t = sum(alpha_i_k, dims = 1) |> vec
        Z_hat[t] = argmax(alpha_i_t)
        # Use selcted column as new alpha_prev
        alpha_prev = alpha_i_k[:, Z_hat[t]]
    end

    # Calc likelihood and return result
    likelihood = sum(alpha_prev)/sum(alpha_T)
    return Z_hat, likelihood
end
end