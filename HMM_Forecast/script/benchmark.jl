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

#HMM_Forecast.modelValidationOnTestData(optimalModels[8])

# for hh in 1:5
#     qrResult = HMM_Forecast.evaluateLinQR(hh, 10)
#     # aResult = HMM_Forecast.modelValidationOnTestData(optimalModels[hh*2 - 1 ])
#     # bResult = HMM_Forecast.modelValidationOnTestData(optimalModels[hh*2])
#     #baseResult = HMM_Forecast.baselineForecast(hh)
#     println(" \n HH$hh & $(round(qrResult, digits=4)) & \n")
# end


### LinQR
HMM_Forecast.trainLinearQR(1)
# HMM_Forecast.evaluateLinQR(5, 10)
# hhs = 2:4
# for hh in hhs
#     HMM_Forecast.evaluateLinQR(hh, 1)
# end

### LSTM
for hh in 2:5
    #HMM_Forecast.trainLSTMModel(hh, 20)
    evaluateResult = HMM_Forecast.evaluateLSTMModel(hh)
    println(" \n HH$hh & $(round(evaluateResult, digits=4))")
end

HMM_Forecast.trainLSTMModel(1, 10)
HMM_Forecast.evaluateLSTMModel(1)

println("/n ------------------ FINISH ---------------------")