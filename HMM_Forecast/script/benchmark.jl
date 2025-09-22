## Pkg
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, ChangePrecision, Dates, Plots
using HMM_Forecasts

hhs = 2:5

for hh in hhs
    results[hh] = HMM_Forecast.linearQR(hh)
end

println(results)


# @sk_import linear_model: QuantileRegressor

# sklin = pyimport("sklearn.linear_model")
# qr = sklin.QuantileRegressor(quantile=0.95)

# function trainLinQR(regressorMatrix, values)

#     function makeLinQR(quantile, X, y) 
#         qr = QuantileRegressor(quantile=quantile, alpha=0.0, solver="highs")   # you can also set e.g. alpha=0.0, solver="highs"
#         fit!(qr, X, y)
#         return (qr.intercept_, qr.coef_)
#     end
#     X = regressorMatrix
#     y = values
#     # Training
#     intercept = Array{Float64}(undef, 99) 
#     coefficients = Array{Float64, 2}(undef, 99, size(X)[2]) 
#     prevTime = now()
#     for (i, quant) in enumerate(0.01:0.01:0.99)
#         inter, coef = makeLinQR(quant, X, y)
#         intercept[i] = inter
#         coefficients[i, :] = coef
#         prevTime = HMM_Forecast.printTimeAndResetTimeStamp(prevTime)
#     end
#     return intercept, coefficients
# end

# function forecastLinQR(regressorMatrix, (intercept, coefficients))
#     T = size(regressorMatrix)[1] 
#     forecastVector = Array{Float64}(undef, T)
#     for i in 1:T
#         forecastVector[i] = intercept + coefficients * regressorMatrix[i, :]'
#     end
#     return forecastVector
# end


# function linearQR(hh)
#     prevTime = now()
#     originalObservations = HMM_Forecast.loadOriginalData(hh)
#     trainDataIndeces = HMM_Forecast.trainDataIndeces()
#     testDataIndeces = HMM_Forecast.testDataIndeces()

#     # Preprocessing: Generate Regressor Matrix and filter for non NaN values
#     println("### Preprocessing ###")
#     X = HMM_Forecast.translateDataToQRMatrixX(originalObservations, 1:length(originalObservations))
#     X_train = X[trainDataIndeces, :]
#     y_train = originalObservations[trainDataIndeces]
#     X_test = X[testDataIndeces, :]
#     y_test = originalObservations[testDataIndeces]
#     prevTime = HMM_Forecast.printTimeAndResetTimeStamp(prevTime)


#     # # Training
#     intercept, coefficients = trainLinQR(X_train, y_train)
#     println("### Training ###")
#     prevTime = HMM_Forecast.printTimeAndResetTimeStamp(prevTime)

#     # # Forecast
#     # forecastVector = forecastLinQR(X_test, (intercept, coefficients))
#     # println("### Forecast ###")
#     # prevTime = printTimeAndResetTimeStamp(prevTime)

#     # CRPS
#     meanCRPS = 0.
#     # T = length(y_test)
#     # for i in 1:T
#     #     meanCRPS += crpsScore(forecastVector[i], y_test[i])/T
#     # end

#     return meanCRPS
# end

# include("data.jl");
# trainData = trainDataSummer
# testData = testDataSummer


# forecast = HMM_Forecast.generateBaselineForecast(observationSpace, trainData, length(testData))

# ## Evaluate models
# (mape, r_sqare, crps) = HMM_Forecast.calcEvaluationGivenForecast(observationSpace, testData, forecast)
# HMM_Forecast.printEvaluation("Baseline model Summer", ((0,0), mape, r_sqare, crps))

# ## Naives model
# naivePred = HMM_Forecast.naivePrediction(trainData, testData)
# HMM_Forecast.evalPointForecast(testData, naivePred)


# # Calc Distribution Forecast
# x = 2000
# H = 50
# T = 20
# hmm = hmmSummer(50)

# testDataFallAsIndeces = HMM_Forecast.translateObservationsToIndex(testDataSummer, hmm.observationSpace)
# forecast = HMM_Forecast.forecastDistribution(hmm |> HMM_Forecast.updateHMMNumericalStable, testDataFallAsIndeces[1:x-H], H)
# testDataFallAsIndeces[x-H-T+1:x-H]
# testDataFallAsIndeces[x-H+1:x]
# forecast[1:end]

# p = HMM_Forecast.plotDistributionForecastWithViolin(hmm, testDataSummer[x-H-T+1:x-H], testDataSummer[x-H+1:x], forecast[1:end])
