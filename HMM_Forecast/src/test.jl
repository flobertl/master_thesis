using HiddenMarkovModels: baum_welch as BWAlgoPkg
using Suppressor

export testAll, runUEAll

function testingEquality(testName::String, testingValue, expectedResult, epsilon = 1E-8)
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

# HACK sollte ausgebessert werden
# Test und Save funktion nicht abstrakt genug...
# function testSaveAndLoadCSVTable()
#     name = "Save and Load CSV-Table "
#     table = [1. 2.; 3. 4.]
#     states = [10, 20]
#     windows = [100, 1000]

#     saveCSVTable("archive//test", table, states, windows)
#     resultTable, resultStates, resultWindows = loadCSVTable("archive//test")
#     testingEquality(name, resultTable, table)
# end

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
end

function testDiscretizeEqualSizeBins()
    name = "Discretize data with equal size bins"

    # Test 1
    observations = [1f0, 2f0, 3f0, 4f0]./4
    result, infoBins  = discretizeEqualSizeBins(2, observations)
    expectedResult = [1.5f0, 1.5f0, 3.5f0, 3.5f0] ./4
    testingEquality(name*" 1", result, expectedResult)

    # Test 2
    observations = [1f0, 2f0, 3f0, 4f0, 5f0] ./ 5
    result, infoBins = discretizeEqualSizeBins(2, observations)
    expectedResult = [1.5f0, 1.5f0, 4f0, 4f0, 4f0] ./ 5
    testingEquality(name*" 2", result, expectedResult)
end

function testTransformLinQRData()
    name = "Transform LinQR Data "
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/15households_2years.xlsx"
    df = DataFrame(XLSX.readtable(path, "Sheet1"))
    originalObservations = df[:, string(1)]

    data = originalObservations[1:96*14+1]
    dateIndeces = 1:96*14+1 |> Vector

    X = translateDataToQRMatrixX(data, dateIndeces)

    # 1.Test number of rows with no missing values should be 1 
    n_complete = count(!any(isnan, row) for row in eachrow(X))
    testingEquality(name *"- missing values", n_complete, 1)

    # 2.Test Richtiger Vector
    x_hist = [139.111666700574 1511.63378177219 428.995891147189 242.045665825737 270.040998840332 188.007221561008 1543.45800425212 1367.78387493558 101.856666564941 82.8463334401448 132.826444159614 109.342667049832 87.8046667310926 56.4491111331516 35.9108888838026 69.3976665072973 76.8449999067518 203.531667412652 155.708778211805 167.113444179959 97.5826663547091 86.6654446072048 117.765999518501 47.0222224765354 145.284222751194 143.925555843777 252.931444803873 160.150334167481 146.946111297608 143.834444512262 144.137777879503 274.178222825792 206.27588857015 235.091222127278 147.930555894639 126.418555196126 149.152555423313 112.822889200846 140.175332768758 466.936443413627 2577.91121232775 195.744556172689 168.170110109117 134.127333577474 150.954332987467 215.733556111653 234.646221923828 275.281999376085 200.248777431911 129.790777333578 141.65944442749 97.9951108720573 90.7841112772622 126.902333492703 126.396555921766 156.741999308268 86.4074444664851 83.366444354587 55.8849999745687 67.4277779473199 195.996555667454 180.06077846951 188.263554890951 167.006111229791 106.656777784559 147.826888190376 54.6253331926134 70.3745552486845 145.041222720676 139.983110385471 130.232888878716 100.987110816108 63.8174444410536 78.0091110653346 134.420444573296 159.995777214898 189.009888543022 179.3895556132 128.208111063639 137.908222495185 41.8027778625489 48.3863333808051 146.437110816108 104.653666347927 121.606110975477 38.1645554860433 34.6954446580675 68.6417778438991 62.6660004085964 164.852776760525 188.274778578017 145.248555925157 93.9232222663031 110.918333858914 34.8933332655165 48.3088889651827 132.931554921468 103.48855565389 114.663222164578 58.6153334299723 34.8027778625488 51.6537778642442 82.9156665378147 164.004111735026 172.254444207086 168.312333848741 91.6651112026638 102.486444515652 51.486333296034 34.7633332570394 126.310667334662 123.488889227973 100.968111250135 68.1937776353627 53.6496665530735 34.5941109127469 82.2570000542533 161.134666781955 156.342666625976 168.60766720242 127.715444437663 84.0917778015137 59.8521108839248 55.9357776641846 80.0265555063884 123.330333709717 172.571110534668 134.128000556098 111.64344490899 167.021222432454 152.108111063639 193.182668219673 247.406889004177 214.645444403754 171.69455540975 664.511329650877 176.860777282715 335.545111592609 187.627222866483 198.314111158582 206.065444268121 184.348890007867 112.659333123102 132.781888241238 100.467333136664 81.5853335486518 196.429110548231 195.604443868002 138.998111300999 89.6560001797145 113.820445209079 34.3171112908258 35.7795555962458 147.740555233426 102.689666493734 93.9979999966092 70.8025557623969 34.174111090766 34.2302222357855 75.4616667853457 170.902222018772 155.117111375597 163.940555318196 99.7135550604931 71.5569997999404 77.6923331790499 105.742110866971 148.738333299425 136.163444010416 155.284556410048 55.0934445063273 33.8476666556464 76.3123339758978 568.66433152093 217.626667192247 182.61133304172 176.961666191948 89.963444773356 88.5572222391763 103.584778001573 64.4850000593397 123.730556106567 128.222667015923 145.03744430542 50.5404446919759 50.9512219323052 80.2126665751137 66.0394446902806 158.161889224582 167.70755581326 188.419999525282 87.9673332214356 1126.1249994066 101.114888254802]'
    dateTime = dateTimesOf2YearsData()[96*14+1]
    dateTime_Scaled = ((Dates.hour(dateTime) + Dates.minute(dateTime)/60) * (2*pi/24), Dates.month(dateTime) * (2*pi/12))
    x_time = [sin(dateTime_Scaled[1]), cos(dateTime_Scaled[1]), sin(dateTime_Scaled[2]), cos(dateTime_Scaled[2])]
    x = vcat(x_hist, x_time)
    testingEquality(name*"- correct values", X[96*14+1, :], x, 1E-3)
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
    # testSaveAndLoadCSVTable() auskommentiert, da function loadCSV nun Tuple erwartet und deswegen mit testbsp nicht zurecht kommt. Bissl ein HACK
    testNormalize()
    #testLoadAndNormalizeData() auskommentiert um Geschwindigkeit zu garantieren
    testDiscretizeEqualMassBins()
    testDiscretizeEqualSizeBins()
    testTransformLinQRData()
end

function runUEAll()
    testUeBsp1()
    testUeBsp2()
    testUeBsp3()
end
