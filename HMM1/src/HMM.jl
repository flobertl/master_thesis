module HMM_Forecast

include("types.jl")
include("helpers.jl")
include("data.jl")
include("calc.jl")
include("plot.jl")
include("prod.jl")
include("test.jl")

using .Prod

export runSingleTraining, runBestPathPrognosis, runSingleTrainingPkg, plots

end