# Module For Productive Use
module Prod 

using Main.HMM.Types
using Main.HMM.Data
using Main.HMM.Calc
using Main.HMM.Helpers

export runSingleTraining, runBestPathPrognosis,forwardAlgo

function getTestDataDay()
        # Load Data
        path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/PV_2024_09_22.xlsx"
        observations = loadObservations1(path)
    
        # Convert Data
        discreteObser = discretize(observations)
        observationSpace = Set(discreteObser) |> ObservationSpace
        observationsAsIndeces = translateObservationsToIndex(discreteObser, observationSpace)

        return(observationSpace, observationsAsIndeces)
end

function getTestData2Month()
    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/verbrauch_schimek_okt_nov.xlsx"
    observations = loadObservations2(path)

    # Convert Data
    discreteObser = discretize(observations)
    observationSpace = Set(discreteObser) |> ObservationSpace
    observationsAsIndeces = translateObservationsToIndex(discreteObser, observationSpace)

    return(observationSpace, observationsAsIndeces)
end

function runSingleTraining()
    # Set Parameter
    N = 10

    (observationSpace, observationsAsIndeces) = getTestDataDay()

    # Run Algo
    hmm = baumWelchAlgo(observationsAsIndeces, observationSpace, N)

    # Store Output

    # Return Output
    return hmm
end 

function runBestPathPrognosis(hmm, forecastHorizon::Int)
    (_, observationsAsIndeces) = getTestDataDay()

    bestPath = bestPathPrognosis(hmm, observationsAsIndeces, forecastHorizon)
end

end