# Benchmarking models

# Baseline
function generate96qhDistro(observationSpace::ObservationSpace, trainData)::Vector{Vector{Float64}}
    M = observationSpace.dimension
    observations = translateIndexToObservations(collect(1:M), observationSpace)
    
    distributionPerQuarterHour = Vector{Vector{Float64}}(undef, 96)
    for qh in 1:96 
        numberOfQH = length(trainData[qh:96:end])
        distributionPerQuarterHour[qh] = map(i -> count(obser -> obser == observations[i], trainData[qh:96:end])/numberOfQH, 1:M)
        if sum(distributionPerQuarterHour[qh]) != 1
            println("Value qh($qh) is $(sum(distributionPerQuarterHour[qh]))")
        end
    end
    return distributionPerQuarterHour
end

function baselineForecast(hh)
    prevTime = now()
    # Load and preprocess data 
    originalObservations = readAndNormalizeData(hh)
    (observationSpace, infoBins), discreteObservations, discreteObservationsAsIndeces = preprocessing(originalObservations, "B", 300)
   
    # Split Train and Test Data
    testDataOriginal = originalObservations[testDataIndeces()]
    trainData = discreteObservations[trainDataIndeces()]

    # Save first indeces
    prevTime = printTimeAndResetTimeStamp(prevTime, "Data Preprocessing: ")
    firstIndecesModulo96_Training = trainDataIndeces()[1] % 96 # =62
    quarterHourProb = generate96qhDistro(observationSpace, trainData)

    prevTime = printTimeAndResetTimeStamp(prevTime, "Generate empiric 96 qh-distributions: ")
    forecastVector =  Vector{Vector{Float64}}(undef, length(testDataOriginal))
    for (i, index) in enumerate(testDataIndeces())
        qhIndex = (index - firstIndecesModulo96_Training) % 96 + 1
        forecastVector[i] = quarterHourProb[qhIndex]  # First qh should be one, last qh should be 96
    end
    CRPS =  meanCRPSContinuous((observationSpace, infoBins), testDataOriginal, forecastVector)
    prevTime = printTimeAndResetTimeStamp(prevTime, "Calc Forecast and CRPS: ")
    return CRPS
end

# Linear Quantile Regression
function trainLinearQR(hh)
    prevTime = now()
    originalObservations = readAndNormalizeData(hh)

    # Preprocessing: Generate Regressor Matrix and filter for non NaN values
    println("### Preprocessing ###")
    X = translateDataToQRMatrixX(originalObservations, 1:length(originalObservations))
    X_train = X[trainDataIndeces(), :]
    y_train = originalObservations[trainDataIndeces()]
    X_test = X[testDataIndeces(), :]
    y_test = originalObservations[testDataIndeces()]
    prevTime = printTimeAndResetTimeStamp(prevTime)


    # # Training
    intercept, coefficients = trainLinQR(X_train, y_train)
    println("### Total Training ###")
    prevTime = printTimeAndResetTimeStamp(prevTime)
    saveLinQRTrainingsMatrix(hh, (intercept, coefficients))
end

function TEST_trainLinearQR(hh)
    prevTime = now()
    originalObservations = readAndNormalizeData(hh)

    # Preprocessing: Generate Regressor Matrix and filter for non NaN values
    println("### Preprocessing ###")
    X = translateDataToQRMatrixX(originalObservations, 1:length(originalObservations))
    X_train = X[trainDataIndecesTEST(), :]
    y_train = originalObservations[trainDataIndecesTEST()]
    prevTime = printTimeAndResetTimeStamp(prevTime)


    # # Training
    intercept, coefficients = trainLinQR(X_train, y_train)
    println("### Total Training ###")
    prevTime = printTimeAndResetTimeStamp(prevTime)
    saveLinQRTrainingsMatrix(hh, (intercept, coefficients))
end

function evaluateLinQR(hh)    
    prevTime = now()
    
    # Load Model
    (intercept, coefficients) = loadLinQRTrainingsMatrix(hh)


    # Preprocessing: Generate Regressor Matrix and filter for non NaN values
    originalObservations = readAndNormalizeData(hh)
    println("### Preprocessing ###")
    X = translateDataToQRMatrixX(originalObservations, 1:length(originalObservations))
    X_test = X[testDataIndeces(), :]
    y_test = originalObservations[testDataIndeces()]
    prevTime = printTimeAndResetTimeStamp(prevTime)

    # Forecast
    forecastVector = forecastLinQR(X_test, (intercept, coefficients))
    println("### Forecast ###")
    prevTime = printTimeAndResetTimeStamp(prevTime)

    # CRPS
    meanCRPS = 0.
    T = length(y_test)
    for i in 1:T
        meanCRPS += crpsScore(forecastVector[i], y_test[i])/T
    end
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