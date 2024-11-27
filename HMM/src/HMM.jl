module HMM

include("types.jl")
include("data.jl")
include("helpers.jl")
include("calc.jl")
include("prod.jl")
include("test.jl")

using .Prod

export runSingleTraining, runBestPathPrognosis

end