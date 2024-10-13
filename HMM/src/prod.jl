include("calc.jl")
include("data.jl")


using Main.Types
using Main.Data
using Main.Calc

# Module For Productive Use
module Prod 


function runSingleTraining()
    # Set Parameter
    N = 10

    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/PV_2024_09_22.xlsx"
    observations = Main.Data.loadObservations(path)

    # Convert Data
    discreteObser = Main.Data.discretize(observations)
    observationSpace = Set(discreteObser) |> Main.Types.ObservationSpace

    # Run Algo
    hmm = Main.Calc.BaumWelchAlgo(discreteObser, observationSpace, N)

    # Store Output

    # Return Output
    return hmm
end

end