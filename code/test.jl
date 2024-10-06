include("core.jl")

let y = HMMCore.Probability(0.2)
println(y)

#%% Calculations
transMatrix = map(HMMCore.Probability, zeros(2,2))

#%% Calculations
x = HMMCore.A(UInt64(2), transMatrix)
println(x)

end