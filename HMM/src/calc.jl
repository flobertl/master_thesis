include("types.jl")
using .Types

module Calc 

function forward(T, HMM::Main.Types.HMM, observations::Array{Int})
    alpha = zeros(T,HMM.numberOfStateSpace)
    for i in 1:HMM.numberOfStateSpace
        alpha[1,i] = HMM.startingDistribution[i]*HMM.observationMatrix[i]
    end
end

function BaumWelchAlgo(Z, V, N::Int)
    # Init
    transMatrixA = ones(N,N) ./ N
    A = Main.Types.A(N, transMatrixA)

    M = length(V.observations)
    transMatrixB =  ones(N,M) ./ M
    B = Main.Types.B((N,M), transMatrixB)

    pi = transMatrixA[1,:] |> Main.Types.StochasticVector
    # Expecatation 


    # Maximization

    # Terminate

    # Return Value
    return Main.Types.HMM(N,A,B,pi,V)
end

end
