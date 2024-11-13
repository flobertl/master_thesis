module Test

using Main.HMM.Types, Main.HMM.Helpers, Main.HMM.Calc, Main.HMM.Data

export testAll

epsilon = 1E-10

function testingEquality(testName::String, testingValue, expectedResult)
    if (expectedResult < testingValue - epsilon) & (expectedResult > testingValue + epsilon)  #evtl muss mann Epsilon einbauen
        println("FAILED Test:", testName)
    else
        println("Sucess Test: ", testName)
    end
end

function testForwardCalc()
    name = "Helper forwardCalc1"

    alpha_tminus1 = ones(4)
    a_point_i = ones(4)
    b_point_o_t = ones(4)
    value = sum(Main.HMM.Helpers.forwardCalc(alpha_tminus1, a_point_i, b_point_o_t))

    testingEquality(name, value, 4)

    name = "Helper forwardCalc2"

    alpha_tminus1 = [1., 2.]
    a_point_i = [3., 4.]
    b_point_o_t = [5., 6.]
    value = sum(Main.HMM.Helpers.forwardCalc(alpha_tminus1, a_point_i, b_point_o_t))

    testingEquality(name, value, 63)    
end

function testBackwardCalc()
    name = "Helper backwardCalc1"

    beta_tplus1 = ones(7)
    a_i_point = ones(7)
    b_point_o_tplus1 = ones(7)
    value = sum(Main.HMM.Helpers.backwardCalc(beta_tplus1, a_i_point, b_point_o_tplus1))

    testingEquality(name, value, 7)

    name = "Helper backwardCalc2"

    beta_tplus1 = [1., 2.]
    a_i_point = [3., 4.]
    b_point_o_tplus1 = [5., 6.]
    value = sum(Main.HMM.Helpers.backwardCalc(beta_tplus1, a_i_point, b_point_o_tplus1))

    testingEquality(name, value, 63)    
end

function testObservationToIndexMapping()
    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/PV_2024_09_22.xlsx"
    observations = loadObservations(path)

    # Convert Data
    discreteObser = discretize(observations)
    observationSpace = Set(discreteObser) |> ObservationSpace

    observationsAsIndices = translateObservationsToIndex(discreteObser, observationSpace)
    reconvertedObservations = translateIndexToObservations(observationsAsIndices, observationSpace)
    testingEquality("ObservationToIndexMapping1", reconvertedObservations, discreteObser)
end

function testBackwardVsForwardAlgo()
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/PV_2024_09_22.xlsx"
    observations = loadObservations(path)

    # Convert Data
    Z = discretize(observations)
    V = Set(Z) |> ObservationSpace

    # Init
    N = 10
    transMatrixA = ones(N,N) ./ N
    a = A(N, transMatrixA)
    M = length(V.observations)
    transMatrixB =  ones(N,M) ./ M
    b = B((N,M), transMatrixB)
    pi = transMatrixA[1,:] |> StochasticVector
    T = length(Z)
    hmm_init = HMM(N, a, b, pi, V)

    # Running Algos 
    (alpha, likelihood1) = forwardAlgo(T, hmm_init, Z)
    (beta, likelihood2) = backwardAlgo(T, hmm_init, Z)

    # Test equality
    testingEquality("Back vs Forward Algo via Likelihood", likelihood1, likelihood2)
    
end


function testAll()
    testForwardCalc()
    testObservationToIndexMapping()
    testBackwardCalc()
end

end