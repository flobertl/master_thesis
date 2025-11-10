## Pkg
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise
using HMM_Forecast

# Optimal HMM models
optimalModels = [
    (1, "A", 40, 100)
    (1, "B", 80, 100)
    (2, "A", 30, 100)
    (2, "B", 40, 100)
    (3, "A", 50, 50)
    (3, "B", 50, 100)
    (4, "A", 60, 100)
    (4, "B", 50, 100)
    (5, "A", 40, 100)
    (5, "B", 80, 100)
]

HMM_Forecast.modelValidationOnTestData(optimalModels[10])



#HMM_Forecast.trainLinearQR(5)
HMM_Forecast.evaluateLinQR(5)
# hhs = 1:5
# for hh in hhs
#     HMM_Forecast.evaluateLinQR(hh)
# end

println("/n ------------------ FINISH ---------------------")