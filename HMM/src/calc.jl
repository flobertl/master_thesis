module Calc 

using Main.HMM.Types

export forward, BaumWelchAlgo

function forward(T, hmm::HMM, observations::Array{Int})
    alpha = zeros(T,hmm.numberOfStateSpace)
    for i in 1:hmm.numberOfStateSpace
        alpha[1,i] = hmm.startingDistribution[i]*hmm.observationMatrix[i]
    end
end

function BaumWelchAlgo(Z, V, N::Int)
    # Init
    transMatrixA = ones(N,N) ./ N
    a = Main.HMM.Types.A(N, transMatrixA)

    M = length(V.observations)
    transMatrixB =  ones(N,M) ./ M
    b = B((N,M), transMatrixB)

    pi = transMatrixA[1,:] |> StochasticVector
    # Expecatation 


    # Maximization

    # Terminate

    # Return Value
    return HMM(N,a,b,pi,V)
end

end
