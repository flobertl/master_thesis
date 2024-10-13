include("../src/prod.jl")

x = Prod.runSingleTraining()
x.transitionMatrix.transitionMatrix[1,2]=2
t = sum(x.transitionMatrix.transitionMatrix, dims=2)
