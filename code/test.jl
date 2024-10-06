include("core.jl")

let y = HMMCore.Probability(0.2)
println(y)

#%% Calculations
transMatrix = map(HMMCore.Probability, zeros(2,3))

#%% Calculations
x = HMMCore.B((2,2), transMatrix)
println(x)

a = (2, 4)

(dim1, dim2) = a
dim1


println(x)
end 