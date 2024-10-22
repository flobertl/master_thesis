# Module For Productive Use
module Prod 

using Main.HMM.Types
using Main.HMM.Data
using Main.HMM.Calc

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

    # Run Algo
    hmm = BaumWelchAlgo(discreteObser, observationSpace, N)

    # Store Output

    # Return Output
    return hmm
end

end