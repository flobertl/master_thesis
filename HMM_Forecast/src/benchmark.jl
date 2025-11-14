# Benchmarking models
using Statistics

# Baseline
function generate96qhEmpiricQuantiles(trainData)::Vector{Vector{Float64}}

    quantileForecastPerQuarterHour = Vector{Vector{Float64}}(undef, 96)
    for qh in 1:96 
        quantileForecastPerQuarterHour[qh] = [quantile(trainData[qh:96:end], quant, sorted=false) for quant in 0.01:0.01:0.99]
    end
    return quantileForecastPerQuarterHour
end

function historicSsamplingBaseline(hh)
    prevTime = now()
    # Load and preprocess data 
    originalObservations = readAndNormalizeData(hh)
   
    # Split Train and Test Data
    trainDataOriginal = originalObservations[trainDataIndeces()]
    testDataOriginal = originalObservations[testDataIndeces()]

    # Get empirical quarter-hourly distributions
    prevTime = printTimeAndResetTimeStamp(prevTime, "Data Preprocessing: ")
    firstIndecesModulo96_Training = trainDataIndeces()[1] % 96 # = 62
    
    quarterHourProb = generate96qhEmpiricQuantiles(trainDataOriginal)

    prevTime = printTimeAndResetTimeStamp(prevTime, "Generate empiric 96 qh-distributions: ")
    
    # Generate Forecast for Test Data 
    forecastVector =  Vector{Vector{Float64}}(undef, length(testDataOriginal))
    for (i, index) in enumerate(testDataIndeces())
        qhIndex = (index - firstIndecesModulo96_Training) % 96 + 1
        forecastVector[i] = quarterHourProb[qhIndex]  # First qh should be one, last qh should be 96
    end
    
    # Calculate CRPS
    meanCRPS = 0.
    T = length(testDataIndeces())
    for i in 1:T
        meanCRPS += crpsScore(forecastVector[i], testDataOriginal[i])/T
    end
    prevTime = printTimeAndResetTimeStamp(prevTime, "Calc Forecast and CRPS: ")
    plotPITHistogramFromQuantilesForecast(testDataOriginal, forecastVector, "Baseline Model HH=$hh") |> display
    return meanCRPS
end

function persistanceBaseline(hh)
    prevTime = now()
    # Load and preprocess data 
    originalObservations = readAndNormalizeData(hh)
   
    # Split Train and Test Data
    trainDataOriginal = originalObservations[trainDataIndeces()]
    testDataOriginal = originalObservations[testDataIndeces()]
    trainDataOriginalShiftedByOne = originalObservations[trainDataIndeces() .- 1]
    testDataOriginalShiftedByOne = originalObservations[testDataIndeces() .- 1]

    # Get empirical quarter-hourly distributions
    prevTime = printTimeAndResetTimeStamp(prevTime, "Data Preprocessing: ")
    firstIndecesModulo96_Training = trainDataIndeces()[1] % 96 # = 62

    trainDataOriginalShiftedByOne = originalObservations[trainDataIndeces() .- 1]
    error = trainDataOriginal .- trainDataOriginalShiftedByOne
    
    distributionOfErrorPerQH = generate96qhEmpiricQuantiles(error)

    prevTime = printTimeAndResetTimeStamp(prevTime, "Generate empiric 96 qh-distributions: ")
    
    # Generate Forecast for Test Data 
    forecastVector =  Vector{Vector{Float64}}(undef, length(testDataOriginal))
    for (i, index) in enumerate(testDataIndeces())
        qhIndex = (index - firstIndecesModulo96_Training) % 96 + 1
        forecastVector[i] = testDataOriginalShiftedByOne[i] .+ distributionOfErrorPerQH[qhIndex]  # First qh should be one, last qh should be 96
    end
    
    # Calculate CRPS
    meanCRPS = 0.
    T = length(testDataIndeces())
    for i in 1:T
        meanCRPS += crpsScore(forecastVector[i], testDataOriginal[i])/T
    end
    prevTime = printTimeAndResetTimeStamp(prevTime, "Calc Forecast and CRPS: ")
    plotPITHistogramFromQuantilesForecast(testDataOriginal, forecastVector, "Baseline Model HH=$hh") |> display
    return meanCRPS
end


# Linear Quantile Regression
function trainLinearQR(hh, historicWindowLength = 10 )
    prevTime = now()
    originalObservations = readAndNormalizeData(hh)

    # Preprocessing: Generate Regressor Matrix and filter for non NaN values
    println("### Preprocessing ###")
    X = translateDataToQRMatrixX(originalObservations, 1:length(originalObservations), historicWindowLength)
    X_train = X[trainDataIndeces(), :]
    y_train = originalObservations[trainDataIndeces()]
    prevTime = printTimeAndResetTimeStamp(prevTime)

    # # Training
    intercept, coefficients = trainLinQR(X_train, y_train)
    println("### Total Training ###")
    prevTime = printTimeAndResetTimeStamp(prevTime)
    saveLinQRTrainingsMatrix(hh, (intercept, coefficients), historicWindowLength)
end

function evaluateLinQR(hh, historicWindowLength = 10)    
    prevTime = now()
    
    # Load Model
    (intercept, coefficients) = loadLinQRTrainingsMatrix(hh, historicWindowLength)


    # Preprocessing: Generate Regressor Matrix and filter for non NaN values
    originalObservations = readAndNormalizeData(hh)
    println("### Preprocessing ###")
    X = translateDataToQRMatrixX(originalObservations, 1:length(originalObservations), historicWindowLength)
    X_test = X[testDataIndeces(), :]
    y_test = originalObservations[testDataIndeces()]
    prevTime = printTimeAndResetTimeStamp(prevTime)

    # Forecast
    forecastVector = forecastLinQR(X_test, (intercept, coefficients))
    println("### Forecast ###")
    # println(forecastVector[1])
    # prevTime = printTimeAndResetTimeStamp(prevTime)

    for index1 in eachindex(forecastVector)
        forecastVector[index1] = sort(forecastVector[index1])
    end

    # # CRPS
    meanCRPS = 0.
    T = length(y_test)
    for i in 1:T
        meanCRPS += crpsScore(forecastVector[i], y_test[i])/T
    end
    plotPITHistogramFromQuantilesForecast(y_test, forecastVector, "LinQR Model HH=$hh") |> display

    return meanCRPS
end

# Naive Predictor

function naivePrediction(trainData, testData)
    naivePred = [trainData[end]]
    for i in 2:length(testData)
        push!(naivePred, testData[i-1])
    end
    return naivePred
end

function evalPointForecast(observations, pointForecast)
    H = length(pointForecast)
    relativeErrors = zeros(Float64, H)
    for i in 1:H
        relativeErrors[i] = (pointForecast[i] - observations[i])/observations[i] |> abs
    end
    return sum(relativeErrors)/H
end


# LSTM models
funct