include("../src/main.jl")

using .HMM

x = runSingleTraining() 

x.observationSpace.mapObservationToIndex
