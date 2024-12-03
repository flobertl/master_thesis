module HMM

include("types.jl")
include("helpers.jl")
include("data.jl")
include("calc.jl")
include("prod.jl")
include("test.jl")

using .Prod

export runSingleTraining, runBestPathPrognosis, runSingleTrainingPkg

end