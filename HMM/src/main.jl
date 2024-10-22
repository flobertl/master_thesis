module HMM

include("types.jl")
include("data.jl")
include("calc.jl")
include("prod.jl")

using .Prod

export runSingleTraining 

end