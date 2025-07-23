using HiddenMarkovModels: baum_welch as BWAlgoPkg
using Suppressor

export testAll, runUEAll

epsilon = 1E-8

function testingEquality(testName::String, testingValue, expectedResult)
    if all((expectedResult .< testingValue .+ epsilon) .& (expectedResult .> testingValue .- epsilon))  #evtl muss mann Epsilon einbauen
        println("Sucess Test: ", testName)
    else
        println("FAILED Test: ", testName)
    end
end

function testObservationToIndexMapping()
    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/PV_2024_09_22.xlsx"
    observations = loadObservations1(path)

    # Convert Data
    discreteObser = discretize(observations)
    observationSpace = Set(discreteObser) |> ObservationSpace

    observationsAsIndices = translateObservationsAsIntToIndex(discreteObser, observationSpace)
    reconvertedObservations = translateIndexToObservations(observationsAsIndices, observationSpace)
    testingEquality("ObservationToIndexMapping1", reconvertedObservations, discreteObser)
end

function testBackwardAndForwardAlgo()
    A_ = A(2, [0.5 0.5; 0.5 0.5])
    B_ = B((2,2), [2/3 1/3; 1/3 2/3])
    pi = StochasticVector([3/4, 1/4])
    obserSpace = ObservationSpace(Set([1,2]))
    hmm = HMM(2, A_, B_, pi, obserSpace)
    observations = [2, 2]

    name = "forwardAlgo"
    alpha, likelihood = forwardAlgo(hmm, observations)
    expectedResult = log(5/24)
    testingEquality(name, likelihood, expectedResult)
    # println("expected: $expectedResult ; result: $likelihood")


    name = "backwardAlgo"
    alpha, likelihood = backwardAlgo(hmm, observations)
    expectedResult = log(5/24)
    testingEquality(name, likelihood, expectedResult)
    # println("expected: $expectedResult ; result: $likelihood")
end

function testBackwardVsForwardAlgo1()
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
    (alpha, loglikelihood1) = forwardAlgo(hmm_init, Z)
    (beta, loglikelihood2) = backwardAlgo(hmm_init, Z)

    # Test equality
    testingEquality("Back vs Forward Algo via Likelihood", loglikelihood1, loglikelihood2)
    # println("expected: $loglikelihood1 ; result: $loglikelihood2")

end

function testBackwardVsForwardAlgo2()
    A_ = A(2,[0.75 0.25; 0.45 0.55])
    B_ = B((2,3), [0.1 0.3 0.6; 0.75 0.2 0.05])
    pi = StochasticVector([0.5, 0.5])
    obserSpace = ObservationSpace(Set([1,2, 3]))

    hmm = HMM(2, A_, B_, pi, obserSpace)
    observations = [1, 2, 2, 3]

    alpha, likelihood1 = forwardAlgo(hmm, observations)
    (beta, likelihood2) = backwardAlgo(hmm, observations)
    expectedResult = log(0.011522617187500002)
    testingEquality("testBackwardVsForwardAlgo", likelihood1, likelihood2)
end

function testUeBsp1()
    A_ = A(2,[0.95 0.05; 0 1])
    B_ = B((2,2), [0.99 0.01; 0.7 0.3])
    pi = StochasticVector([0.85, 0.15])
    obserSpace = ObservationSpace(Set([1,2]))

    hmm = HMM(2, A_, B_, pi, obserSpace)
    observations = [1, 2, 1]

    alpha, likelihood = forwardAlgo(hmm, observations)
    expectedResult = log(0.038684140875)
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
    expectedResult = log(0.011522617187500002)
    testingEquality("Ue Bsp2", likelihood, expectedResult)
end

function testUeBsp3()
    A_ = A(2,[0.5 0.5; 0.4 0.6])
    B_ = B((2,4), [0.2 0.3 0.3 0.2; 0.3 0.2 0.2 0.3])
    pi = StochasticVector([0.5, 0.5])
    obserSpace = ObservationSpace(Set([1, 2, 3, 4]))

    hmm = HMM(2, A_, B_, pi, obserSpace)
    observations = [1, 1, 1, 4, 4]

    alpha, likelihood = forwardAlgo(hmm, observations)
    expectedResult = log(0.001081288)
    #println(alpha, likelihood)
    testingEquality("Ue Bsp3", likelihood, expectedResult)

end

function testBWAlgo()
    name = "Test BW-Algo"
    A_ = A(2,[0.5 0.5; 0.5 0.5])
    B_ = B((2,2), [2/3 1/3; 1/3 2/3])
    pi = StochasticVector([3/4, 1/4])
    obserSpace = ObservationSpace(Set([1,2]))

    hmm = HMM(2, A_, B_, pi, obserSpace)
    observations = [2, 2]

    hmm, likelihood = @suppress baumWelchAlgo(hmm, observations, 1)
    expectedResult = log(5/24)
    testingEquality(name, likelihood, expectedResult)
    # println("expected: $expectedResult ; result: $likelihood")
end

function testConvertHMM()
    A_ = A(2,[0.5 0.5; 0.5 0.5])
    B_ = B((2,2), [2/3 1/3; 1/3 2/3])
    pi = StochasticVector([3/4, 1/4])
    obserSpace = ObservationSpace(Set([1,2]))

    hmm = HMM(2, A_, B_, pi, obserSpace)
    observations = [2, 2]

    x = transformHMMToPkgHMM(hmm)
    # println("Test Success: Transform HMM")
end

function testBWAlgoWithPkg()
    name = "Test BW-Algo with Pkg"
    A_ = A(2,[0.95 0.05; 0 1])
    B_ = B((2,2), [0.99 0.01; 0.7 0.3])
    pi = StochasticVector([0.85, 0.15])
    obserSpace = ObservationSpace(Set([1,2]))
    observations = [1, 2, 2, 1]

    hmm1 = HMM(2, A_, B_, pi, obserSpace)
    hmm2 = transformHMMToPkgHMM(hmm1)

    hmm3, result1 = @suppress baumWelchAlgo(hmm1, observations, 3)
    hmm4, result2 = BWAlgoPkg(hmm2, observations, max_iterations = 3)
    return result1, result2
end

function testBestPathPrognosis()
    name = "Test Best Path Prognosis"
    A_ = A(3,[0.2 0.6 0.2; 0.1 0.1 0.8; 0.8 0.1 0.1])
    B_ = B((3,3), [1 0 0; 0 1 0; 0 0 1])
    pi = StochasticVector([0, 0, 1])
    obserSpace = ObservationSpace(Set([1, 2, 3]))
    observations = [3]

    hmm1 = HMM(3, A_, B_, pi, obserSpace)

    result1, liklihood = bestPathPrognosis(hmm1, observations, 3)
    expectedResult = [1, 2, 3]
    testingEquality(name, result1, expectedResult)
end

function testForecastDistribution()
    name = "Test distribution forecast"
    A_ = A(3,[0.2 0.6 0.2; 0.1 0.1 0.8; 0.8 0.1 0.1])
    B_ = B((3,3), [1 0 0; 0 1 0; 0 0 1])
    pi = StochasticVector([0, 0, 1])
    obserSpace = ObservationSpace(Set([1, 2, 3]))
    observations = [3]

    hmm1 = HMM(3, A_, B_, pi, obserSpace)

    result = forecastDistribution(hmm1, observations, 2)
    expectedResult = [[0.8, 0.1, 0.1], [0.25, 0.5, 0.25]]
    testingEquality(name*"[part 1]", result[1], expectedResult[1])
    # println("expected: $(expectedResult[1]) ; result: $(result[1])")

    testingEquality(name*"[part 2]", result[2], expectedResult[2])
    # println("expected: $(expectedResult[2]) ; result: $(result[2])")
end

function testUpdateHMMWithStationaryDistro()
    name = "Test updating HMM with stationary Distro"
    A_ = A(2, [1 2; 2 1]./3 )
    B_ = B((2,2), [1 0; 1 0])
    pi = StochasticVector([0, 1])
    obserSpace = ObservationSpace(Set([1, 2]))

    oldHMM = HMM(2, A_, B_, pi, obserSpace)

    result = updateHMMWithStationaryInitDistro(oldHMM).startingDistribution.probabilities
    expectedResult = [1/2 1/2]
    testingEquality(name*" 1", result, expectedResult)

    A_ = A(3, [0.6 0.2 0.2; 0.3 0.3 0.4; 0.1 0.4 0.5] )
    B_ = B((3,2), [1 0; 1 0; 0 2 ])
    pi = StochasticVector([0, 1, 0])
    obserSpace = ObservationSpace(Set([1, 2, 3]))

    oldHMM = HMM(3, A_, B_, pi, obserSpace)

    result = updateHMMWithStationaryInitDistro(oldHMM).startingDistribution.probabilities
    expectedResult = [0.322033898305085, 0.3050847457627117, 0.3728813559322034]
    testingEquality(name*" 2", result, expectedResult)
end

function testSaveAndLoadHMM()
    name = "Save and Load HMM"
    A_ = A(3,[0.2 0.6 0.2; 0.1 0.1 0.8; 0.8 0.1 0.1])
    B_ = B((3,3), [1 0 0; 0 1 0; 0 0 1])
    pi = StochasticVector([0, 0, 1])
    obserSpace = ObservationSpace(Set([1, 2, 3]))
    hmm1 = HMM(3, A_, B_, pi, obserSpace)

    saveHMM(hmm1, "testSaveAndLoadHmm.txt")
    hmm = loadHMM("testSaveAndLoadHmm.txt")
    if (hmm == hmm1)
        println("Sucess Test: ", name)
    else
        println("FAILEDD Test: ", name)
    end
end

function testTimestamps()
    name = "Test adding Timestamps"
    obser = [10 20 30 10 20 30 10 20 30]
    result = addTimestamps(32, obser)
    expectedResult = [10, 20, 30, 11, 21, 31, 12, 22, 32]
    testingEquality(name, result, expectedResult)
end

function testTranslateForecastDistributionTimestampsToOriginal()
    name = "Test translation from timestamp to original forecast distribution"
    obserSpaceOriginal = ObservationSpace(Set([10, 20]))
    obserSpaceTimestamps = ObservationSpace(Set([11, 12, 21, 22]))
    forecastOriginal = [0.6, 0.4]
    forecastTimestamps = [[0.2, 0.4, 0.1, 0.3]]

    testingEquality(name, translateTimestampsToOriginalDistributionForecast(obserSpaceTimestamps,obserSpaceOriginal,forecastTimestamps)[1], forecastOriginal)
end

function testMeasure()
    name = "Measures "
    obserSpace = ObservationSpace(Set([1, 2]))
    distro = [1/4, 3/4]
    observation = 2

    testingEquality(name*"mean", mean(obserSpace, distro), 1.75)
    testingEquality(name*"variance", variance(obserSpace, distro), 3/16)
    testingEquality(name*"pinball 1", pinball(obserSpace, observation, distro, 0.5), 0.)
    testingEquality(name*"pinball 2", pinball(obserSpace, observation, distro, 0.1), 0.1)
    meanForecast1 = transformDistributionToMeanPointForecast(obserSpace, [distro])
    testingEquality(name*"mae", mae_forPointForecast([observation], meanForecast1), 0.25)
    meanForecast2 = transformDistributionToMeanPointForecast(obserSpace, [distro, distro])
    testingEquality(name*"variance of error 1", residualVariance_forPointForecast([observation; observation], meanForecast2), 0)
    testingEquality(name*"variance of error 2", residualVariance_forPointForecast([observation; [1]], meanForecast2), 0.5)
    distro = [[1 , 0], [1/4, 3/4]]
    observation = [1, 2] 
    testingEquality(name*"R^2", r_squared_forMeanPointForecast(obserSpace, observation, distro), 1-0.25^2/0.5)
end

function testSaveAndLoadCSVTable()
    name = "Save and Load MAE Table "
    table = [1 2; 3 4]
    states = [10, 20]
    windows = [100, 1000]

    saveCSVTable("archive//test", table, states, windows)
    resultTable, resultStates, resultWindows = loadCSVTable("archive//test")
    testingEquality(name, resultTable, table)
end

function testNormalize()
    name = "Normalize by max Element"
    vec = [4., 2., 1.]
    
    result = normalizeWithMaxElement(vec)
    expectedResult = [1f0, 1/2f0, 1/4f0] 
    testingEquality(name, result, expectedResult)
end

function testLoadAndNormalizeData()
    name = "Load and Normalize data"
    
    result = readAndNormalizeData(1)[1]
    expectedResult = 0.02124232f0
    testingEquality(name, result, expectedResult)
end

function testDiscretizeEqualMassBins()
    name = "Discretize data with equal mass bins"

    # Test 1
    observations = [1f0, 2f0, 3f0, 4f0]./4
    result, infoBins = discretizeEqualMassBins(2, observations)
    expectedResult, expectedInfoBins = ([1.5f0, 1.5f0, 3.5f0, 3.5f0] ./4, [(0, 2.5/4), (2.5/4, 1-2.5/4)])
    testingEquality(name*" 1A", result, expectedResult)


    # Test 2
    observations = [1f0, 2f0, 3f0, 4f0, 5f0] ./ 5
    result, infoBins = discretizeEqualMassBins(2, observations)
    expectedResult = [2f0, 2f0, 2f0, 4.5f0, 4.5f0] ./ 5
    testingEquality(name*" 2", result, expectedResult)
    println(infoBins)
end

function testDiscretizeEqualSizeBins()
    name = "Discretize data with equal size bins"

    # Test 1
    observations = [1f0, 2f0, 3f0, 4f0]./4
    result, infoBins  = discretizeEqualSizeBins(2, observations)
    expectedResult = [1.5f0, 1.5f0, 3.5f0, 3.5f0] ./4
    testingEquality(name*" 1", result, expectedResult)
    println(infoBins)

    # Test 2
    observations = [1f0, 2f0, 3f0, 4f0, 5f0] ./ 5
    result, infoBins = discretizeEqualSizeBins(2, observations)
    expectedResult = [1.5f0, 1.5f0, 4f0, 4f0, 4f0] ./ 5
    testingEquality(name*" 2", result, expectedResult)
    println(infoBins)
end


function testAll()
    testObservationToIndexMapping()
    testBackwardAndForwardAlgo()
    testBackwardVsForwardAlgo1()
    testBackwardVsForwardAlgo1()
    testConvertHMM()
    testBWAlgoWithPkg()
    testBWAlgo()
    testBestPathPrognosis()
    testForecastDistribution()
    testTimestamps()
    testMeasure()
    testUpdateHMMWithStationaryDistro()
    testTranslateForecastDistributionTimestampsToOriginal()
    testSaveAndLoadCSVTable()
    testNormalize()
    #testLoadAndNormalizeData() auskommentiert um Geschwindigkeit zu garantieren
    testDiscretizeEqualMassBins()
    testDiscretizeEqualSizeBins()

end

function runUEAll()
    testUeBsp1()
    testUeBsp2()
    testUeBsp3()
end
