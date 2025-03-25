using Random

function forwardAlgo(hmm::HMM, observations::Vector{Int})
    T = length(observations)
    N = hmm.numberOfStateSpace
    alpha = zeros(Float64, T, N)
    likelihood_step = zeros(T)

    # Init
    for i in 1:N
        alpha[1,i] = hmm.startingDistribution.probabilities[i]*hmm.observationMatrix.transitionMatrix[i,observations[1]]
    end
    likelihood_step[1] = sum(alpha[1,:])
    alpha[1,:] = alpha[1,:] / likelihood_step[1] 

    # Iteration
    for t in 2:T
        for i in 1:N    
            zwischenresultat = alpha[t-1,:] .* hmm.transitionMatrix.transitionMatrix[:,i] .* hmm.observationMatrix.transitionMatrix[i, observations[t]]
            alpha[t,i] = sum(zwischenresultat)
        end 
        likelihood_step[t] = sum(alpha[t,:])
        alpha[t,:] = alpha[t,:] ./ sum(alpha[t,:])
    end

    # Terminate
    loglikelihood = map(log, likelihood_step) |> sum

    return (alpha, loglikelihood)
end

function backwardAlgo(hmm::HMM, observations::Vector{Int})
    T = length(observations)
    N = hmm.numberOfStateSpace

    #Init 
    beta = ones(Float64, T, N)
    likelihood_step = zeros(Float64, T)

    # Calc
    for t in T-1:-1:1
        for i in 1:N
            zwischenResultat = beta[t+1,:] .* hmm.transitionMatrix.transitionMatrix[i,:] .* hmm.observationMatrix.transitionMatrix[:,observations[t+1]]
            beta[t,i] = sum(zwischenResultat)
        end
        likelihood_step[t+1] = sum(beta[t,:])
        beta[t,:] = beta[t,:] ./ sum(beta[t,:])
    end

    # Terminate
    likelihood_step[1] = (beta[1,:] .* hmm.startingDistribution.probabilities[:] .* hmm.observationMatrix.transitionMatrix[:,observations[1]])|> sum
    loglikelihood = map(log, likelihood_step) |> sum

    return (beta, loglikelihood)
end

function baumWelchAlgo(initHMM::HMM, observations, maxIter::Int = 100)
    # Parameters
    T = length(observations)
    N = initHMM.transitionMatrix.dimension
    M = initHMM.observationSpace.dimension
    observationSpace = initHMM.observationSpace

    likelihood_prev_prev = 0
    likelihood_prev = 0
    loglikelihood_next = nextfloat(0.0)

    # Init values for tracking iteration and time
    iter = 1
    time_prev = time()

    # Init values
    hmm = initHMM
    a = hmm.transitionMatrix
    b = hmm.observationMatrix
    pi = hmm.startingDistribution
    alpha = zeros(Float64, T, N)

    # Init likelihood for tracking convergence
    likelihood_prev = -floatmax(Float64)
    loglikelihood_next = nextfloat(0.0)

    for x in 1:maxIter
        # Expecatation 
        (alpha, loglikelihood_next) = forwardAlgo(hmm, observations)
        (beta, _) = backwardAlgo(hmm, observations)

        # Termination Condition: termination when likelihood declines two times in a row
        if (loglikelihood_next - likelihood_prev < 0.5)
            println("Breaking Condition fullfilled.")
            break
        end
        likelihood_prev = loglikelihood_next

        gamma = zeros(Float64, T-1, N, N)
        transMatrixA_hat = zeros(Float64, N,N)
        transMatrixB_hat = zeros(Float64, N,M)

        # Calculation of gamma
        for t in 1:(T-1)
            for i in 1:N 
                for j in 1:N 
                    gamma[t,i,j] = alpha[t,i] * a.transitionMatrix[i,j] * b.transitionMatrix[j, observations[t+1]] * beta[t+1,j]
                end
            end
            gamma_norm = sum(gamma[t,:,:])
            for i in 1:N 
                for j in 1:N 
                    gamma[t,i,j] = gamma[t,i,j]/gamma_norm
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
        accurances = Array{Any}(undef, M) 
        for k in 1:M
            accurances[k] = findall(obs -> obs == k, observations[1:end-1])     # Returns all the times observation k occured.
        end

        for i in 1:N 
            summe = sum(gamma[:,i,:])
            for k in 1:M
                if (summe != 0)
                   transMatrixB_hat[i,k] = sum(gamma[accurances[k],i,:])/summe
                end
            end
        end

        a = A(N, transMatrixA_hat)
        b = B((N,M), transMatrixB_hat)
        hmm = HMM(N, a, b, pi, observationSpace)

        # Tracking iteration and timing
        now = time()
        println("BW-Algo: ", iter, ".iteration taking ", (now - time_prev), " LogLiklihood: ", loglikelihood_next)
        time_prev = now
        iter += 1
    end

    # Return Value
    return HMM(N,a,b,pi,observationSpace), loglikelihood_next
end

function bestPathPrognosis(hmm::HMM, observations, forecastHorizon::Int, initAlpha_T::Vector{Float64} = [0.0])
    # Set parameter
    T = length(observations)
    N, M = hmm.observationMatrix.dimension  # N = #hiddenStates, B = #observationStates
    
    # Step 0: Calc alpha(T)
    if initAlpha_T == [0.]
        alpha_T = forwardAlgo(hmm, observations)[1][T,:]
    else
        alpha_T = initAlpha_T
    end

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

function forecastDistribution(hmm::HMM, observations, forecastHorizon::Int)::Vector{Vector{Float64}}
    # Set parameter
    T = length(observations)
    
    # Step 0: Calc alpha(T)
    alpha_T = forwardAlgo(hmm, observations)[1][T,:]

    # Init Step: Alocate alpha_i^k(T+1), Z_hat
    forecast = Vector{Vector{Float64}}(undef, forecastHorizon)
    alpha_prev = alpha_T

    # Rec Step:
    for t in 1:forecastHorizon 
        # Calc alpha_i_k
        alpha_prev = (alpha_prev' * hmm.transitionMatrix.transitionMatrix)'
        forecast[t] = (alpha_prev' * hmm.observationMatrix.transitionMatrix)'
    end

    for index1 in eachindex(forecast)
        for index2 in eachindex(forecast[index1])
            if isnan(forecast[index1][index2])
                forecast[index1][index2] = 0.
            end
        end
    end

    return forecast
end

function forecastDistributionWithAlpha(hmm::HMM, forecastHorizon::Int, initAlpha_T::Vector{Float64})
    # Set parameter
    N, M = hmm.observationMatrix.dimension  # N = #hiddenStates, B = #observationStates

    # Init Step: Alocate alpha_i^k(T+1), Z_hat
    forecast = Vector{Vector{Float64}}(undef, forecastHorizon)
    alpha_prev = initAlpha_T

    # Rec Step:
    for t in 1:forecastHorizon 
        # Calc alpha_i_k
        alpha_prev = (alpha_prev' * hmm.transitionMatrix.transitionMatrix)'
        forecast[t] = (alpha_prev' * hmm.observationMatrix.transitionMatrix)'
    end

    for index1 in eachindex(forecast)
        for index2 in eachindex(forecast[index1])
            if isnan(forecast[index1][index2])
                forecast[index1][index2] = 0.0
            end
        end
    end

    return forecast, alpha_prev
end



