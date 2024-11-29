module Test

using Main.HMM.Types, Main.HMM.Helpers, Main.HMM.Calc, Main.HMM.Data, Main.HMM.Prod

export testAll, runUEAll

epsilon = 1E-10

function testingEquality(testName::String, testingValue, expectedResult)
    if all((expectedResult .< testingValue .- epsilon) .& (expectedResult .> testingValue .+ epsilon))  #evtl muss mann Epsilon einbauen
        println("FAILED Test:", testName)
    else
        println("Sucess Test: ", testName)
    end
end

function testForwardCalc()
    name = "Helper forwardCalc1"
    alpha_tminus1 = ones(4)
    a_point_i = ones(4)
    b_i_o_t = 1.
    value = sum(Main.HMM.Helpers.forwardCalc(alpha_tminus1, a_point_i, b_i_o_t))
    testingEquality(name, value, 4)

    name = "Helper forwardCalc2"
    alpha_tminus1 = [1., 2.]
    a_point_i = [3., 4.]
    b_i_o_t = 5.
    value = sum(Main.HMM.Helpers.forwardCalc(alpha_tminus1, a_point_i, b_i_o_t))
    testingEquality(name, value, 55)    
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
    b_point_o_tplus1 = [5. , 6.]
    value = sum(Main.HMM.Helpers.backwardCalc(beta_tplus1, a_i_point, b_point_o_tplus1))
    testingEquality(name, value, 63)   
     
end

function testObservationToIndexMapping()
    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/PV_2024_09_22.xlsx"
    observations = loadObservations1(path)

    # Convert Data
    discreteObser = discretize(observations)
    observationSpace = Set(discreteObser) |> ObservationSpace

    observationsAsIndices = translateObservationsToIndex(discreteObser, observationSpace)
    reconvertedObservations = translateIndexToObservations(observationsAsIndices, observationSpace)
    testingEquality("ObservationToIndexMapping1", reconvertedObservations, discreteObser)
end

function testBackwardAndForwardAlgo()
    A_ = A(2,[0.5 0.5; 0.5 0.5])
    B_ = B((2,2), [2/3 1/3; 1/3 2/3])
    pi = StochasticVector([3/4, 1/4])
    obserSpace = ObservationSpace(Set([1,2]))
    hmm = HMM(2, A_, B_, pi, obserSpace)
    observations = [2, 2]

    name = "forwardAlgo"
    alpha, likelihood = forwardAlgo(hmm, observations)
    expectedResult = 5/24
    testingEquality(name, likelihood, expectedResult)

    name = "backwardAlgo"
    alpha, likelihood = backwardAlgo(hmm, observations)
    expectedResult = 5/24
    testingEquality(name, likelihood, expectedResult)
end

function testBackwardVsForwardAlgo()
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/PV_2024_09_22.xlsx"
    observations = loadObservations1(path)

    # Convert Data
    V, Z = getTestDataDay()

    # Init
    N = 10
    transMatrixA = createRandomTransitionMatrixViaDirichlet(N, N)
    a = A(N, transMatrixA)
    M = length(V.observations)
    transMatrixB =  createRandomTransitionMatrixViaDirichlet(N, M)
    b = B((N,M), transMatrixB)
    pi = transMatrixA[1,:] |> StochasticVector
    T = length(Z)
    hmm_init = HMM(N, a, b, pi, V)

    # Running Algos 
    (alpha, likelihood1) = forwardAlgo(hmm_init, Z)
    (beta, likelihood2) = backwardAlgo(hmm_init, Z)

    # Test equality
    testingEquality("Back vs Forward Algo via Likelihood", likelihood1, likelihood2)
    
end

function testUeBsp1()
    A_ = A(2,[0.95 0.05; 0 1])
    B_ = B((2,2), [0.99 0.01; 0.7 0.3])
    pi = StochasticVector([0.85, 0.15])
    obserSpace = ObservationSpace(Set([1,2]))

    hmm = HMM(2, A_, B_, pi, obserSpace)
    observations = [1, 2, 1]

    alpha, likelihood = forwardAlgo(hmm, observations)
    expectedResult = 0.38684140875
    testingEquality("Ue Bsp1", likelihood, expectedResult)
end

function testUeBsp2()
    A_ = A(2,[0.75 0.25; 0.45 0.55])
    B_ = B((2,3), [0.1 0.3 0.6; 0.75 0.2 0.05])
    pi = StochasticVector([0.5, 0.5])
    obserSpace = ObservationSpace(Set([1,2, 3]))

    hmm = HMM(2, A_, B_, pi, obserSpace)
    observations = [1, 2, 2, 3]

    alpha, likelihood = forwardAlgo(hmm, observations)
    0.011522617187500002
    expectedResult = 0.011522617187500002
    testingEquality("Ue Bsp2", likelihood, expectedResult)

end

function testAll()
    testForwardCalc()
    testObservationToIndexMapping()
    testBackwardCalc()
    testBackwardAndForwardAlgo()
    testBackwardVsForwardAlgo()
end

function runUEAll()
    testUeBsp1()
    testUeBsp2()
end

end