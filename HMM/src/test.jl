module Test

using Main.HMM.Types, Main.HMM.Helpers, Main.HMM.Calc, Main.HMM.Data

export testAll

epsilon = 1E-10

function testingEquality(testName::String, testingValue, expectedResult)
    if (expectedResult < testingValue) & (expectedResult > testingValue)  #evtl muss mann Epsilon einbauen
        println("Test:", testName, " FAILED")
    else
        println("Test: ", testName, " succeded")
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


function testAll()
    testForwardCalc()
    testObservationToIndexMapping()
    testBackwardCalc()
end

end