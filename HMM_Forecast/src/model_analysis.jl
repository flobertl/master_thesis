# Function to run BasisModel runBasisModelAnalysis
using Random, Printf, Plots

# PIT 
function plotPITHistogramYear(hh, discretTyp::String, numberOfObservations::Int, numberOfStates, historicWindowLength = 20)
    # Data
    originalObservations = readAndNormalizeData(hh)
    (observationSpace, infoBins), discreteObservations, discreteObservationsAsIndeces = preprocessing(originalObservations, discretTyp, numberOfObservations)
    evalDataIndeces = validationDataIndeces()

    N = numberOfStates
    # Load HMM model and evaluate
    filename = @sprintf("basismodel_hh(%02d)_diskr(%c%03d)_states(%03d)", hh, discretTyp, numberOfObservations, N)
    hmm = loadHMM("hyperparameter_analysis/models/"*filename) |> updateHMMNumericalStable  
    
    # Create Forecast and PIT Histogram
    distributionForecastVector = calcSlidingWindowPrediction(hmm, discreteObservationsAsIndeces, evalDataIndeces, historicWindowLength)
    pitHistogram = plotPITHistogram((observationSpace, infoBins), originalObservations[evalDataIndeces], distributionForecastVector, "PIT Histhogram for HH$hh")
    
    # Save PIT histogram
    folderPath = "HMM_Forecast/tmp/model_analysis/pitFullYear/"
    fileName = @sprintf("histogramPIT_hh(%02d)_diskr(%c%03d)_states(%03d)", hh, discretTyp, numberOfObservations, N)
    savefig(pitHistogram, folderPath*fileName)

    return pitHistogram
end

function plotPITHistogramDaytime(hh, discretTyp::String, numberOfObservations::Int, numberOfStates, historicWindowLength = 20)
    # Data
    originalObservations = readAndNormalizeData(hh)
    (observationSpace, infoBins), discreteObservations, discreteObservationsAsIndeces = preprocessing(originalObservations, discretTyp, numberOfObservations)
    evalDataIndeces = validationDataIndeces()
    testData = originalObservations[evalDataIndeces]
    numberOfDays = length(testData)/96 |> floor |> Int

    N = numberOfStates
    # Load HMM model and evaluate
    filename = @sprintf("basismodel_hh(%02d)_diskr(%c%03d)_states(%03d)", hh, discretTyp, numberOfObservations, N)
    hmm = loadHMM("hyperparameter_analysis/models/"*filename) |> updateHMMNumericalStable 
    
    distributionForecastVector = calcSlidingWindowPrediction(hmm, discreteObservationsAsIndeces, evalDataIndeces, historicWindowLength)


    moriningIndices = [6*4 + 96*i + j for i in 0:numberOfDays-1, j in 1:24] |> vec
    middayIndeces = [12*4 + 96*i + j for i in 0:numberOfDays-1, j in 1:24] |> vec
    eveningIndices = [18*4 + 96*i + j for i in 0:numberOfDays-1, j in 1:24] |> vec
    nightIndeces = [1 + 96*i + j for i in 0:numberOfDays-1, j in 1:24] |> vec
        
    pit0300 = HMM_Forecast.plotPITHistogram((observationSpace, infoBins), testData[moriningIndices], distributionForecastVector[moriningIndices], "Morning")
    pit0900 = HMM_Forecast.plotPITHistogram((observationSpace, infoBins), testData[middayIndeces], distributionForecastVector[middayIndeces], "Midday")
    pit01500 = HMM_Forecast.plotPITHistogram((observationSpace, infoBins), testData[eveningIndices], distributionForecastVector[eveningIndices], "Evening")
    pit2100 = HMM_Forecast.plotPITHistogram((observationSpace, infoBins), testData[nightIndeces], distributionForecastVector[nightIndeces], "Night")
    pitSpecificDaytimes = plot(pit0300, pit0900, pit01500, pit2100, layout=(2,2), suptitle = "PIT Histogramms for HH$hh"  )
    
    # Save PIT histogram
    folderPath = "HMM_Forecast/tmp/model_analysis/pitDaytimes/"
    savefig(pitSpecificDaytimes, folderPath*"hh(%).png")

    return pitSpecificDaytimes
end

# Calcs the evaluation (CRPS) for basismodel in folder 'hyperparameter_analysis'. 
# See section 'Hyperparameter Analysis' for detailed methodology
function plotExampleViolinForecastforBasismodel(hh, discretTyp::String, numberOfObservations::Int, numberOfStates, timeinstance, historicWindowLength = 20, forecastHorizon = 1)
    # Data
    originalObservations = readAndNormalizeData(hh)
    (observationSpace, infoBins), discreteObservations, discreteObservationsAsIndeces = preprocessing(originalObservations, discretTyp, numberOfObservations)
    evalDataIndeces = validationDataIndeces()


    N = numberOfStates
    # Load HMM model
    filename = @sprintf("basismodel_hh(%02d)_diskr(%c%03d)_states(%03d)", hh, discretTyp, numberOfObservations, N)
    hmm = loadHMM("hyperparameter_analysis/models/"*filename) |> updateHMMNumericalStable  
    
    # Create Forecast and PIT Histogram
    historicObservationsAsIndeces = discreteObservationsAsIndeces[ evalDataIndeces[timeinstance] - historicWindowLength + 1: evalDataIndeces[timeinstance]]
    historicObservations = originalObservations[ evalDataIndeces[timeinstance] - historicWindowLength + 1: evalDataIndeces[timeinstance]]
    futureObservation =  originalObservations[ (evalDataIndeces[timeinstance] + 1): (evalDataIndeces[timeinstance] + forecastHorizon)]

    distributionForecastVector = forecastDistribution(hmm, historicObservationsAsIndeces, forecastHorizon)
    violinPlot = plotDistributionForecastWithViolin(hmm, historicObservations,futureObservation, distributionForecastVector, filename*" at t($timeinstance)")
    
    # Save PIT histogram
    # folderPath = "HMM_Forecast/tmp/plots/"
    # fileName = @sprintf("histogramPIT_hh(%02d)_diskr(%c%03d)_states(%03d)", hh, discretTyp, numberOfObservations, N)
    # savefig(pitHistogram, folderPath*fileName)

    return violinPlot
end

### Generates a histogram for the convergence points of a model
function plotConvergencePointsHistogram(hh, discretTyp::String, numberOfObservations::Int, numberOfStates, historicWindowLength = 20, forecastHorizon = 10, atol = 0.1)
    # Data
    originalObservations = readAndNormalizeData(hh)
    (observationSpace, infoBins), discreteObservations, discreteObservationsAsIndeces = preprocessing(originalObservations, discretTyp, numberOfObservations)
    evalDataIndeces = validationDataIndeces()  #preliminary test with small data set

    # Load HMM model and evaluate
    filename = @sprintf("basismodel_hh(%02d)_diskr(%c%03d)_states(%03d)", hh, discretTyp, numberOfObservations, numberOfStates)
    hmm = loadHMM("hyperparameter_analysis/models/"*filename) |> updateHMMNumericalStable  
    
    # Create Forecast and PIT Histogram
    convergencePoints = []

    for (i, testIndex) in enumerate(evalDataIndeces[1:end-forecastHorizon])
        # generate forecast vector
        forecastVector = forecastDistribution(hmm, discreteObservationsAsIndeces[testIndex-historicWindowLength:testIndex-1], forecastHorizon)

        # calc convergence point
        push!(convergencePoints, calcConcergencePoint(hmm, forecastVector, atol))
    end

    convergencePointsFiltered = (filter(x -> !isnan(x), convergencePoints)) .|> Int

    # Print how many forecasts did not converge
    notConverged = count(Base.isnan, convergencePoints)
    println("Number of not converged forecasts: $notConverged from $(length(convergencePoints)) forecasts.")

    # Plot histogram
    h = fit(Histogram, convergencePointsFiltered, 1:maximum(convergencePointsFiltered) ) 
    if atol == 0.1
        xlimmax = 40
    elseif atol == 0.01
        xlimmax = 80
    else
        xlimmax = forecastHorizon
    end

    convergencePointsHistogram = 
        histogram(convergencePoints, 
            bins = forecastHorizon, 
            title = "Convergence Points for HH$hh with $atol tolerance", 
            xlabel = "Convergence Point", 
            ylabel = "Frequency", 
            xlim = (1, xlimmax),
            ylim=(0, maximum(h.weights) * 1.04),
            legend = false, 
            framestyle = :box,
            bar_width = 0.8)    
    
    # Save Convergence histogram
    folderPath = "HMM_Forecast/tmp/model_analysis/convergence_points/"
    fileName = @sprintf("tol(%02dprozent)/histogramConvergencePoints_hh(%02d)_diskr(%c%03d)_states(%03d)", (atol*100 |> Int), hh, discretTyp, numberOfObservations, numberOfStates)
    savefig(convergencePointsHistogram, folderPath*fileName)

    return convergencePointsHistogram
end