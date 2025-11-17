# Benchmarking models
using Flux, Statistics, Random

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
##############################################

# --------------------
# Hyperparameter
# --------------------
const FEAT   = 5               # Anzahl Eingangsfeatures pro Zeitschritt
const L      = 96*2            # Lookback: 2 Tage
const H      = 1              # Horizon: 1 viertelstunde
const ALPHAS = collect(0.01:0.07:0.99)  # 14 Quantile
const K      = length(ALPHAS)
const HIDDEN = 64
const batchSize = 1024

# --------------------
# Pinball-Loss
# --------------------
@inline function pinball(y, q, α)
    e = y - q
    return e ≥ 0 ? α*e : (α-1)*e
end
function monotone_penalty(q::AbstractVector)
    s = 0.0
    @inbounds for i in 1:length(q)-1
        d = q[i] - q[i+1]
        if d > 0
            s += d
        end
    end
    return s
end



# --------------------
# Loss for a batch
# ytrue: (H, batch)  ;  ypred: (K, H, batch)
# --------------------
function loss_batch(model, x, ytrue; λ=1f-3)
    Flux.reset!(model)            # LSTM-States pro Batch resetten
    ŷ = model(x)                 # (K, H, B)
    K, H_, B = size(ŷ)
    @assert H_ == H

    s   = 0.0f0
    pen = 0.0f0

    @inbounds for b in 1:B, h in 1:H, k in 1:K
        s += pinball(ytrue[h, b], ŷ[k, h, b], ALPHAS[k])
    end

    @inbounds for b in 1:B, h in 1:H
        pen += monotone_penalty(view(ŷ, :, h, b))
    end

    return s/(B*H*K) + λ*pen/(B*H)
end



function trainLSTMModel(hh, numEpochs::Int)
    # -------------------
    # Model: LSTM -> Dense to K*H outputs
    # --------------------
    myModel = Chain(
        LSTM(FEAT=> HIDDEN),          # 1) LSTM über die Zeitachse
        LastStepLayer(),           # 2) letzten Zeitschritt nehmen: (hidden, batch)  
        Dense(HIDDEN => 128, relu),    # 1st hidden layer
        Dense(128 => 64, relu),        # 2nd hidden layer
        Dense(64 => K*H),         # 3) K*H Outputs
        ReshapeLayer(K, H)
    )
    opt_state = Flux.setup(Adam(1e-3), myModel)


    # --------------------
    # Data
    # --------------------
    originalObservations = HMM_Forecast.readAndNormalizeData(hh)
    trainDataIndeces = HMM_Forecast.trainDataIndeces()
    x_val, y_val = createDataForLSTM(L, H, originalObservations, validationDataIndeces())
    validation_loss_old, validation_loss_new = 1., 1.

    # Trainingsphase
    for epoch in 1:numEpochs
        println("### Epoch $epoch ###")
        batches = createBatchesForLSTM(batchSize, originalObservations, trainDataIndeces)
        prevTime = now()

        for (i, (x, y)) in enumerate(batches)
            # Expliziter Gradient über das Modell
            grads = Flux.gradient(myModel) do m
                loss_batch(m, x, y; λ=1f-3)
            end

            # Update mit Optimizer-State + Modell + Gradienten
            Flux.update!(opt_state, myModel, grads[1])

            current_loss = loss_batch(myModel, x, y; λ=1f-3)
            prevTime = printTimeAndResetTimeStamp(prevTime, "Batch $i/$(length(batches)) Batch Loss: $current_loss")
        end
        validation_loss_old = validation_loss_new 
        validation_loss_new = loss_batch(myModel, x_val, y_val)
        println("Validation Loss: $validation_loss_new")
        if validation_loss_old < validation_loss_new
            break
        end
    end
    saveLSTM(hh, myModel)

    return validation_loss_new
end

function evaluateLSTMModel(hh)
    model = loadLSTM(hh)
    originalObservations = HMM_Forecast.readAndNormalizeData(hh)
    testDataIndeces = HMM_Forecast.testDataIndeces()
    x_test, y_test = createDataForLSTM(L, H, originalObservations, testDataIndeces)

    y_estimate = model(x_test)                 # (K, H, B)
    forecastVector = Vector{Vector{Float64}}(undef, length(testDataIndeces))
    for t in 1:length(testDataIndeces)
        if H == 1 ### FOR NOW Only implemeneted for H = 1
            y_estimate[:, 1, t] = sort(y_estimate[:, 1, t])
        else
            throw(DomainError(H, "H must be 1 for now"))
        end
        forecastVector[t] = [y_estimate[1, 1, t] ]
        for i in 1:K-1        # Logik: es startet bei quantil 0.01 und geht bis 0.99. Aber um jedes 1%-quantil zu bekommen,
            spread = 0.98/(K-1)*100 |> round  
            if (t, i) == (1, 1) println("spread: $spread") end
            quantiles = [y_estimate[i, 1, t] + (k/spread) * (y_estimate[i+1, 1, t] - y_estimate[i, 1, t]) for k in 1:spread]
            append!(forecastVector[t], quantiles)
        end
    end

    # # CRPS
    meanCRPS = 0.
    T = length(y_test)
    for i in 1:T
        meanCRPS += crpsScore(forecastVector[i], y_test[i])/T
    end
    return meanCRPS
end