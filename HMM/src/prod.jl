# Module For Productive Use
module Prod 

using Main.HMM.Types
using Main.HMM.Data
using Main.HMM.Calc
using Main.HMM.Helpers

export runSingleTraining

function runSingleTraining()
    # Set Parameter
    N = 10

    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/PV_2024_09_22.xlsx"
    observations = loadObservations(path)

    # Convert Data
    discreteObser = discretize(observations)
    observationSpace = Set(discreteObser) |> ObservationSpace
    observationsAsIndeces = translateObservationsToIndex(discreteObser, observationSpace)

    # Run Algo
    hmm = BaumWelchAlgo(observationsAsIndeces, observationSpace, N)

    # Store Output

    # Return Output
    return hmm
end

end