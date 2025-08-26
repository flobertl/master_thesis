# Function to run BasisModel runBasisModelAnalysis
using Random, Printf, Plots

function calcEvaluation((hmm, infoBins), discretizedDataAsIndeces, (trainDateIndeces, testDateIndeces), testDataOriginal, historicWindowLength)
    # Calc Prediction
    distributionForecastVector = calcSlidingWindowPrediction(hmm, discretizedDataAsIndeces, testDateIndeces, historicWindowLength)::Vector{Vector{Float64}}

    # Calc Likelihood
    loglikelihood_train = loglikelihood(hmm, discretizedDataAsIndeces[trainDateIndeces])
    loglikelihood_test = loglikelihood(hmm, discretizedDataAsIndeces[testDateIndeces])

    # Calc CRPS
    crps = meanCRPSContinuous((hmm.observationSpace, infoBins), testDataOriginal, distributionForecastVector)

    return ((loglikelihood_test,loglikelihood_train), crps)
end

# Calcs the evaluation (CRPS) for basismodel in folder 'hyperparameter_analysis'. 
# See section 'Hyperparameter Analysis' for detailed methodology
function hyperparameterAnalysis(hh, discretTyp::String, numberOfObservationsVector::Vector{Int}, numberOfStatesVector = 30:5:60, historicWindowLength = 100)
    # Data
    originalObservations = readAndNormalizeData(hh)
    dateIndeces = calcFirstQHofYearAndMonth()  
    trainDateIndeces = dateIndeces[2,1]:dateIndeces[3,1]-1 |> Vector      
    testDateIndeces = validationDataIndeces()
    testDataOriginal = originalObservations[testDateIndeces]

    results = Array{Tuple{Tuple{Float64, Float64}, Float64} , 2}(undef, (length(numberOfObservationsVector), length(numberOfStatesVector)))

    println("------------------ Evaluate basismodel_hh($hh) with discretization $discretTyp --------------------")
    prevTime = now()
    for (i, numberOfObservations) in enumerate(numberOfObservationsVector)
        (observationSpace, infoBins), discreteObservations, discreteObservationsAsIndeces = preprocessing(originalObservations, discretTyp, numberOfObservations)
        for (j, N) in enumerate(numberOfStatesVector)
            # Load HMM model and evaluate
            filename = @sprintf("basismodel_hh(%02d)_diskr(%c%03d)_states(%03d)", hh, discretTyp, numberOfObservations, N)
            hmm = loadHMM("hyperparameter_analysis/models/"*filename) |> updateHMMNumericalStable  
            result = calcEvaluation((hmm, infoBins), discreteObservationsAsIndeces, (trainDateIndeces, testDateIndeces), testDataOriginal, historicWindowLength)
            results[i, j] = result
            printEvaluation(filename, result)
            prevTime = printTimeAndResetTimeStamp(prevTime)
        end
    end
    resultsFile = @sprintf("hyperparameter_analysis/results/basismodel_hh(%02d)_diskr(%c)",hh, discretTyp)
    saveResultsTable(resultsFile, results, numberOfObservationsVector, numberOfStatesVector)
    return results
end

# Loads saved csv table and plots
function plotHyperparameterAnalysis(hh, numberOfObservationsVector, numberOfStatesVector)
    folderPath = "hyperparameter_analysis/"
    modelName =  @sprintf("basismodel_hh(%02d)", hh)
    crpsTable = []
    for discretTyp in ["A", "B"]
        discretTypeName = @sprintf("_diskr(%c)", discretTyp)
        resultsTable = loadResultsTable(folderPath*"results/"*modelName*discretTypeName, numberOfObservationsVector, numberOfStatesVector)
        push!(crpsTable , getindex.(resultsTable, 2))
    end
    pltCRPS = plotHyperparameterAnalysisCRPS(hh, crpsTable, numberOfObservationsVector, numberOfStatesVector, "# Observations")

    savefig(pltCRPS, "HMM_Forecast/tmp/"*folderPath*"plots/"*modelName*"_CRPS")
    display(pltCRPS)
    # loglikeTestTable = getindex.(getindex.(resultsTable, 1), 1)
    # pltLoglike = plotHyperparameterAnalysisLoglike("Loglike "*fileName, loglikeTestTable, numberOfObservationsVector, numberOfStatesVector, "# Observations")
    # savefig(pltLoglike, "HMM_Forecast/tmp/"*folderPath*"plots/"*fileName*"_Loglike")
    # display(pltLoglike)
end

# Calcs the evaluation (CRPS) for basismodel in folder 'hyperparameter_analysis'. 
# See section 'Hyperparameter Analysis' for detailed methodology
function plotPITforBasismodel(hh, discretTyp::String, numberOfObservations::Int, numberOfStates, historicWindowLength = 100)
    # Data
    originalObservations = readAndNormalizeData(hh)
    (observationSpace, infoBins), discreteObservations, discreteObservationsAsIndeces = preprocessing(originalObservations, discretTyp, numberOfObservations)
    evalDataIndeces = validationDataIndeces()

    N = numberOfStates
    # Load HMM model and evaluate
    filename = @sprintf("basismodel_hh(%02d)_diskr(%c%03d)_states(%03d)", hh, discretTyp, numberOfObservations, N)
    hmm = loadHMM("hyperparameter_analysis/"*filename) |> updateHMMNumericalStable  
    
    # Create Forecast and PIT Histogram
    distributionForecastVector = calcSlidingWindowPrediction(hmm, discreteObservationsAsIndeces, evalDataIndeces, historicWindowLength)
    pitHistogram = plotPITHistogram((observationSpace, infoBins), originalObservations[evalDataIndeces], distributionForecastVector)
    
    # Save PIT histogram
    folderPath = "HMM_Forecast/tmp/plots/"
    fileName = @sprintf("histogramPIT_hh(%02d)_diskr(%c%03d)_states(%03d)", hh, discretTyp, numberOfObservations, N)
    savefig(pitHistogram, folderPath*fileName)

    return pitHistogram
end

#----------------------------------------------------------------------------------------------------------
# Legacy

    function generatePITforSeasonModels(hmm::HMM, trainData, testData, folderPath::String, name = "")
        trainDataAsIndeces = translateObservationsAsIntToIndex(trainData, hmm.observationSpace)
        testDataAsIndeces = translateObservationsAsIntToIndex(testData, hmm.observationSpace)

        # Calc Prediction
        distributionForecastVector = createSeveralOneStepPredictions(hmm, trainDataAsIndeces, testDataAsIndeces)::Vector{Vector{Float64}}

        # Make PIT plots
        pitAllTestData = HMM_Forecast.plotPIT(hmm, testData, distributionForecastVector, "Season")
        pit0300 = HMM_Forecast.plotPIT(hmm, testData[1+3*4:96:end], distributionForecastVector[1+3*4:96:end], "03:00")
        pit0900 = HMM_Forecast.plotPIT(hmm, testData[1+9*4:96:end], distributionForecastVector[1+9*4:96:end], "09:00")
        pit01500 = HMM_Forecast.plotPIT(hmm, testData[1+15*4:96:end], distributionForecastVector[1+15*4:96:end], "15:00")
        pit2100 = HMM_Forecast.plotPIT(hmm, testData[1+21*4:96:end], distributionForecastVector[1+21*4:96:end], "21:00")
        pitSpecificTimes = plot(pit0300, pit0900, pit01500, pit2100, layout=(2,2))
        png(pitAllTestData, folderPath*"pitAllTestData.png")
        png(pitSpecificTimes, folderPath*"pitSpecificTimes.png")

        # Calc Likelihood
        alpha, loglikelihood_train = forwardAlgo(hmm, trainDataAsIndeces)
        alpha, loglikelihood_test = forwardAlgo(hmm, testDataAsIndeces)

        # Calc Entropy


        # Store measures quantities
        open(folderPath*"log_model($(hmm.transitionMatrix.dimension))", "w") do io
            # Save numberOfStateSpace
            println(io, "loglikelihood training:", loglikelihood_train)
            println(io, "loglikelihood test:", loglikelihood_test)
        end
    end

    function generatePITforFullyearModels(hmm::HMM, trainData, testData, folderPath::String)
        trainDataAsIndeces = translateObservationsAsIntToIndex(trainData, hmm.observationSpace)
        testDataAsIndeces = translateObservationsAsIntToIndex(testData, hmm.observationSpace)

        # Calc Prediction
        distributionForecastVector = createSeveralOneStepPredictions(hmm, trainDataAsIndeces, testDataAsIndeces)::Vector{Vector{Float64}}

        # Make PIT plots
        pitAllTestData = HMM_Forecast.plotPIT(hmm, testData, distributionForecastVector, "PIT of all test data")
        # pit0300 = HMM_Forecast.plotPIT(hmm, testData[1+3*4:96:end], distributionForecastVector[1+3*4:96:end], "03:00")
        # pit0900 = HMM_Forecast.plotPIT(hmm, testData[1+9*4:96:end], distributionForecastVector[1+9*4:96:end], "09:00")
        # pit01500 = HMM_Forecast.plotPIT(hmm, testData[1+15*4:96:end], distributionForecastVector[1+15*4:96:end], "15:00")
        # pit2100 = HMM_Forecast.plotPIT(hmm, testData[1+21*4:96:end], distributionForecastVector[1+21*4:96:end], "21:00")
        # pitSpecificTimes = plot(pit0300, pit0900, pit01500, pit2100, layout=(2,2))
        png(pitAllTestData, folderPath*"pitAllTestData.png")
        # png(pitSpecificTimes, folderPath*"pitSpecificTimes.png")

        # Calc Likelihood
        alpha, loglikelihood_train = forwardAlgo(hmm, trainDataAsIndeces)
        alpha, loglikelihood_test = forwardAlgo(hmm, testDataAsIndeces)

        # Calc Entropy


        # Store measures quantities
        open(folderPath*"log_model($(hmm.transitionMatrix.dimension))", "w") do io
            # Save numberOfStateSpace
            println(io, "loglikelihood training:", loglikelihood_train)
            println(io, "loglikelihood test:", loglikelihood_test)
        end
    end

    function calcEvaluationLegacy(hmm::HMM, trainData, testData)
        testDataAsIndeces = translateObservationsAsIntToIndex(testData, hmm.observationSpace)
        trainDataAsIndeces = translateObservationsAsIntToIndex(trainData, hmm.observationSpace)
        hmmStable = hmm |> updateHMMNumericalStable

        # Calc Prediction
        distributionForecastVector = createSeveralOneStepPredictions(hmmStable, trainDataAsIndeces, testDataAsIndeces)::Vector{Vector{Float64}}

        # Calc Likelihood
        loglikelihood_train = loglikelihood(hmmStable, trainData)
        loglikelihood_test = loglikelihood(hmmStable, testData)

        # Calc MAPE
        meanForecast = transformDistributionToMeanPointForecast(hmm.observationSpace, distributionForecastVector)
        mape = mae_forPointForecast(testData, meanForecast)

        # Calc R_squared
        r_sqare = 0 #r_squared_forMeanPointForecast(hmm.observationSpace, testData, distributionForecastVector)

        # Calc CRPS
        crps = meanCRPS(hmm.observationSpace, testData, distributionForecastVector)

        return ((loglikelihood_test,loglikelihood_train), mape, r_sqare, crps)
    end

    function calcEvaluationTimestampModel(hmmTS::HMM, trainDataTS, testDataTS,  obserSpaceOriginal, testDataOriginal)
        testDataAsIndeces = translateObservationsAsIntToIndex(testDataTS, hmmTS.observationSpace)
        trainDataAsIndeces = translateObservationsAsIntToIndex(trainDataTS, hmmTS.observationSpace)
        hmmStable = hmmTS |> updateHMMNumericalStable

        # Calc Likelihood
        loglikelihood_train = loglikelihood(hmmStable, trainDataTS)
        loglikelihood_test = loglikelihood(hmmStable, testDataTS)

        # Calc Prediction
        distributionForecastVectorTimestamp = createSeveralOneStepPredictions(hmmStable, trainDataAsIndeces, testDataAsIndeces)
        distributionForecastVectorOriginal = translateTimestampsToOriginalDistributionForecast(hmmStable.observationSpace, obserSpaceOriginal, distributionForecastVectorTimestamp)

        # Calc prediction measures
        (mape, r_sqare, crps) = calcEvaluationGivenForecast(obserSpaceOriginal, testDataOriginal, distributionForecastVectorOriginal)
        
        return ((loglikelihood_test,loglikelihood_train), mape, r_sqare, crps)
    end

    function printEvaluation(name::String, ((loglikelihood_test,loglikelihood_train), crps))
        println("$name --- loglike-Train: $loglikelihood_train /// loglike-Test: $loglikelihood_test /// Mean CRPS: $crps")
    end

    function calcEvaluationGivenForecast(observationSpace::ObservationSpace, testData, distributionForecastVector)
        # Calc MAPE 
        meanForecast = transformDistributionToMeanPointForecast(hmm.observationSpace, distributionForecastVector)
        mape = mae_forPointForecast(testData, meanForecast)
        # Calc R_squared
        r_sqare = 0 #r_squared_forMeanPointForecast(observationSpace, testData, distributionForecastVector)
        # Calc CRPS
        crps = meanCRPS(observationSpace, testData, distributionForecastVector)

        return (mape, r_sqare, crps)
    end

    function evaluateSeasonmodels(hh = 1, numberOfStatesVector = 5:5:30)
        # Data
        (observationSpace, observations, observationsAsIndeces) = getData2Years_Simplified(hh);
        trainDataIndeces = [trainDataSpringIndeces, trainDataSummerIndeces, trainDataFallIndeces, trainDataWinterIndeces]
        testDataIndeces = [testDataSpringIndeces, testDataSummerIndeces, testDataFallIndeces, testDataWinterIndeces]

        results = [Vector{}() for i in 1:4]
        println("------------------ Evaluate seasonmodel_hh($hh) --------------------")
        for seasonIndex in 1:4
            dataTraining = observations[trainDataIndeces[seasonIndex]]
            dataTest     = observations[testDataIndeces[seasonIndex]]

            prevTime = now()
            loglike = Dict()
            resultSeason = []
            for N in numberOfStatesVector
                # Train and store model 
                hmm = loadHMM("simplified_experiments/seasonmodel_hh($hh)//seasonmodel_"*seasonStrings[seasonIndex]*"_states($N)") |> updateHMMNumericalStable
                result = calcEvaluationLegacy(hmm, dataTraining, dataTest)
                push!(resultSeason, result)
                printEvaluation("seasonmodel_($hh)_"*seasonStrings[seasonIndex]*"_states($N)" , result)
            end
            results[seasonIndex] = resultSeason
            println(" ")
        end
        prevTime = printTimeAndResetTimeStamp(prevTime)
        return results
    end

    function evaluateBasismodelWithTimestamps(hh = 1, numberOfStatesVector = 30:5:60, numberOfTimeBlocksVector = [8])
        # Data
        (obserSpaceOriginal, observationsOriginal, observationsAsIndecesOriginal) = getData2Years_Simplified(hh);

        dateIndeces = calcFirstQHofYearAndMonth()

        dataTestOriginal    = observationsOriginal[dateIndeces[3,1]:endOfDecember20()]

        prevTime = now()
        results = []
        println("------------------ Evaluate basismodel_hh($hh) with timestamps  --------------------")
        for numberOfTimeBlocks in numberOfTimeBlocksVector
            (observationSpace, observationsTS, observationsAsIndecesTS) = getData2Years_SimplifiedAndTimestamps(hh, numberOfTimeBlocks);
            dataTrainingTS = observationsTS[dateIndeces[2,1]:dateIndeces[3,1]-1]
            dataTestTS    = observationsTS[dateIndeces[3,1]:endOfDecember20()]
        
            for N in numberOfStatesVector
                # Train and store model 
                hmm = loadHMM("simplified_experiments/basismodel_timestamps_hh($hh)//basismodel_ts($numberOfTimeBlocks)_states($N)") 
                result = calcEvaluationTimestampModel(hmm, dataTrainingTS, dataTestTS, obserSpaceOriginal, dataTestOriginal)
                push!(results, result)
                printEvaluation("basismodel_ts($numberOfTimeBlocks)_states($N)" , result)
            end
            println(" ")
        end
        prevTime = printTimeAndResetTimeStamp(prevTime)
        return results
    end

    function evaluateAllModels(hhs = [1],  numberOfStatesVector = 30:5:60, numberOfTimeBlocksVector = [8])
        results = Vector() 
        prevTime = now()
        for hh in hhs
            resultHH = Vector()
            #push!(resultHH, evaluateBasismodel(hh, numberOfStatesVector))
            push!(resultHH, evaluateBasismodelWithTimestamps(hh, numberOfStatesVector, numberOfTimeBlocksVector))
            #push!(resultHH, evaluateSeasonmodels(hh, numberOfStatesVector))
            push!(results, resultHH)
        end
        prevTime = printTimeAndResetTimeStamp(prevTime)
        return results
    end

    # Basismodel analysis 2 for varying numbers of states and historic window length
    # Forecast Method: Mean with MAE and Residual Variance
    function evaluateBasismodel2(hh::Int, numberOfStatesVector::Vector{Int}, historicWindowLengthVector::Vector{Int})
        (observationSpace, observations, observationsAsIndeces) = getData2Years_Simplified(hh);
        testDataIndeces = testData2WeeksForAllSeasons
        sampleTestDataIndeces = testDataIndeces #rand(testDataIndeces, length)

        prevTime = now()
        resultsMAE = Array{Float64, 2}(undef, (length(numberOfStatesVector), length(historicWindowLengthVector)))
        resultsResidualVariance = Array{Float64, 2}(undef, (length(numberOfStatesVector), length(historicWindowLengthVector)))

        for (i_states, N) in enumerate(numberOfStatesVector)
            # Train and store model 
            hmm_unchanged = loadHMM("simplified_experiments/basismodel_hh($hh)//basismodel_states($N)") 
            hmm = hmm_unchanged |> updateHMMNumericalStable |> updateHMMWithStationaryInitDistro 
            for (i_hwl, historicWindowLength) in enumerate(historicWindowLengthVector)
                println("------------------ Evaluate basismodel_hh($hh): states($N) historicWindowLength($historicWindowLength) --------------------")
                forecastVector = calcSlidingWindowPrediction(hmm, observationsAsIndeces, sampleTestDataIndeces, historicWindowLength)
                meanForecast = transformDistributionToMeanPointForecast(observationSpace, forecastVector)
                resultsMAE[i_states, i_hwl] = mae_forPointForecast( observations[sampleTestDataIndeces], meanForecast)
                resultsResidualVariance[i_states, i_hwl] = residualVariance_forPointForecast(observations[sampleTestDataIndeces], meanForecast)
                prevTime = printTimeAndResetTimeStamp(prevTime)
            end
        end
        return resultsMAE, resultsResidualVariance
    end 

    # Basismodel analysis 3 for varying numbers of states and historic window length
    # Forecast Method: Best Path (one step = arg max) with accuracy as metrik
    function evaluateBasismodel3(hh::Int, numberOfStatesVector::Vector{Int}, historicWindowLengthVector::Vector{Int})
        (observationSpace, observations, observationsAsIndeces) = getData2Years_Simplified(hh);
        originalObservations = getData2YearsOriginal(hh)
        testDataIndeces = testData2WeeksForAllSeasons
        sampleTestDataIndeces = testDataIndeces #rand(testDataIndeces, length)

        prevTime = now()
        resultsMAE = Array{Float64, 2}(undef, (length(numberOfStatesVector), length(historicWindowLengthVector)))
        resultsAccuracy = Array{Float64, 2}(undef, (length(numberOfStatesVector), length(historicWindowLengthVector)))
        konfusionsMatrix = Array{Array{Float64,2}, 2}(undef, (length(numberOfStatesVector), length(historicWindowLengthVector)))

        for (i_states, N) in enumerate(numberOfStatesVector)
            # Train and store model 
            hmm_unchanged = loadHMM("simplified_experiments/basismodel_hh($hh)//basismodel_states($N)") 
            hmm = hmm_unchanged |> updateHMMNumericalStable |> updateHMMWithStationaryInitDistro 
            for (i_hwl, historicWindowLength) in enumerate(historicWindowLengthVector)
                println("------------------ Evaluate basismodel_hh($hh): states($N) historicWindowLength($historicWindowLength) --------------------")
                forecastVector = calcSlidingWindowPrediction(hmm, observationsAsIndeces, sampleTestDataIndeces, historicWindowLength)
                bestPathForecast = transformDistributionToBestPathPointForecast(observationSpace, forecastVector)
                resultsMAE[i_states, i_hwl] = mae_forPointForecast( originalObservations[sampleTestDataIndeces], map(Float64, bestPathForecast))
                resultsAccuracy[i_states, i_hwl] = accuracy_forPointForecast(observations[sampleTestDataIndeces], bestPathForecast)
                konfusionsMatrix[i_states, i_hwl] = calcKonfusionsMatrix(observationSpace, observationsAsIndeces[sampleTestDataIndeces], translateObservationsAsIntToIndex(bestPathForecast, observationSpace))
                prevTime = printTimeAndResetTimeStamp(prevTime)
            end
        end
        return resultsMAE, resultsAccuracy, konfusionsMatrix
    end



    function basismodelHyperparameterAnalysisAccuracy(hh, numberOfStatesVector::Vector{Int}, historicWindowLengthVector::Vector{Int})
        resultsMAE, resultsResidualVariance, resultsKonfusionsMatrix = evaluateBasismodel3(hh, numberOfStatesVector, historicWindowLengthVector)
        saveCSVTable("hyperparameter_categorical_analysis_hh($hh)_MAE", resultsMAE, numberOfStatesVector, historicWindowLengthVector)
        saveCSVTable("hyperparameter_categorical_analysis_hh($hh)_Accuracy", resultsResidualVariance, numberOfStatesVector, historicWindowLengthVector)
        #saveXLXSTable("hyperparameter_categorical_analysis_hh($hh)_Konfusionsmatrix", resultsKonfusionsMatrix)
        plotMAE(resultsMAE, numberOfStatesVector, historicWindowLengthVector)    
        plotAccuracy(resultsResidualVariance, numberOfStatesVector, historicWindowLengthVector)

        return resultsKonfusionsMatrix
    end

    function evaluateNaiveModel(hh)
        (observationSpace, observations, observationsAsIndeces) = getData2Years_Simplified(hh);
        originalObservations = getData2YearsOriginal(hh)
        testDataIndeces = testData2WeeksForAllSeasons

        predictions = originalObservations[testDataIndeces .- 1] |> float

        resultsMAE = mae_forPointForecast(observations[testDataIndeces], predictions)
        resultsResidualVariance = residualVariance_forPointForecast(originalObservations[testDataIndeces], predictions)
        resultsAccuracy = accuracy_forPointForecast(observations[testDataIndeces], observations[testDataIndeces .- 1])
        return resultsMAE, resultsResidualVariance, resultsAccuracy
    end

    ############################################################################################################################
    ## Legacy Code

    # function evaluateSeasonmodelsWithTimeStamps(numberOfTimeBlocks = 8, numberOfStatesVector = 30:5:60, hh = 1)
    #     # Data
    #     (observationSpace, observations, observationsAsIndeces) = getData2Years_Timestamps(hh, numberOfTimeBlocks);
    #     dates = dateTimesOf2YearsData()
    #     dateIndeces = calcFirstQHofYearAndMonth()
    #     trainDataIndeces = [trainDataSpringIndeces, trainDataSummerIndeces, trainDataFallIndeces, trainDataWinterIndeces]
    #     testDataIndeces = [testDataSpringIndeces, testDataSummerIndeces, testDataFallIndeces, testDataWinterIndeces]

    #     results = [Vector{}() for i in 1:4]
    #     for seasonIndex in 1:4
    #         dataTraining = observations[trainDataIndeces[seasonIndex]]
    #         dataTest     = observations[testDataIndeces[seasonIndex]]

    #         prevTime = now()
    #         loglike = Dict()
    #         resultSeason = []
    #         for N in numberOfStatesVector
    #             # Train and store model 
    #             hmm = loadHMM("seasonmodel_timestamps_hh($hh)//seasonmodel_Ts_"*seasonStrings[seasonIndex]*"_states($N)_timeblocks($numberOfTimeBlocks)") |> updateHMMNumericalStable
    #             result = calcEvaluation(hmm, dataTraining, dataTest)
    #             push!(resultSeason, result)
    #             printEvaluation("seasonmodel_Ts_"*seasonStrings[seasonIndex]*"_states($N)_timeblocks($numberOfTimeBlocks)" , result)
    #         end
    #         results[seasonIndex] = resultSeason
    #     end
    #     return results
    # end

    function calcPITForBasisModel(numberOfStatesVector = 50:50:300, hh = 1) 

        Random.seed!(42)
        
        iter = 50

        # Data
        (observationSpace, observations, observationsAsIndeces) = getData2Years(hh);
        dates = dateTimesOf2YearsData()
        dateIndeces = calcFirstQHofYearAndMonth()

        startIndexTraining  = dateIndeces[2,1] 
        endIndexTraining    = dateIndeces[3,1]-1
        startIndexTest      = dateIndeces[3,1]
        endIndexTest        = endOfDecember20()
        indecesSpring20 = dateIndeces[3,3]:dateIndeces[3,6]-1
        indecesSummer20 = dateIndeces[3,6]:dateIndeces[3,9]-1
        indecesFall20   = dateIndeces[3,9]:dateIndeces[3,12]-1
        indecesWinter20 = vcat(dateIndeces[3,1]:dateIndeces[3,3]-1, dateIndeces[3,12]:endIndexTest)
        
        dataTrainingAsIndeces   = observationsAsIndeces[startIndexTraining:endIndexTraining]
        dataTestAsIndeces       = observationsAsIndeces[startIndexTest:endIndexTest]
        dataTraining            = observations[startIndexTraining:endIndexTraining]
        dataTests               = observations[startIndexTest:endIndexTest]

        prevTime = now()

        for N in numberOfStatesVector
            # Train and store model 
            hmm =  loadHMM("basismodel_hh($hh)//states($N)//basismodel_states($N)") |> updateHMMNumericalStable
    #        # N = 50
            # hmm1 = loadHMM("basismodel_hh(1)//states(1)//basismodel_states(1)")
            prevTime = printTimeAndResetTimeStamp(prevTime)
            
            # Calc Prediction
            println("-------------- Calc forecast distribution for {$N} states------------------")
            distributionForecastVector = createSeveralOneStepPredictions(hmm, dataTrainingAsIndeces, dataTestAsIndeces)::Vector{Vector{Float64}}
            prevTime = printTimeAndResetTimeStamp(prevTime)

            # plotDistributionForecastWithViolin(hmm, dataTraining[end-20:end], dataTests[3301:3320], distributionForecastVector[1:20])
    
            # Generate PIT Plots
            println("-------------- Generate PT plots for {$N} states------------------")
            pitYear = HMM_Forecast.plotPIT(hmm, dataTests, distributionForecastVector, "PIT of Year 2020")
            pitSpring = HMM_Forecast.plotPIT(hmm, observations[indecesSpring20], distributionForecastVector[indecesSpring20 .- (startIndexTest-1)], "Spring")
            pitSummer = HMM_Forecast.plotPIT(hmm, observations[indecesSummer20], distributionForecastVector[indecesSummer20 .- (startIndexTest-1)], "Summer")
            pitFall = HMM_Forecast.plotPIT(hmm, observations[indecesFall20], distributionForecastVector[indecesFall20 .- (startIndexTest-1)], "Fall")
            pitWinter = HMM_Forecast.plotPIT(hmm, observations[indecesWinter20], distributionForecastVector[indecesWinter20 .- (startIndexTest-1)], "Winter")
            pitSeasons = plot(pitSpring, pitSummer, pitFall, pitWinter, layout=(2,2))
            pit0300 = HMM_Forecast.plotPIT(hmm, dataTests[1+3*4:96:end], distributionForecastVector[1+3*4:96:end], "03:00")
            pit0900 = HMM_Forecast.plotPIT(hmm, dataTests[1+9*4:96:end], distributionForecastVector[1+9*4:96:end], "09:00")
            pit01500 = HMM_Forecast.plotPIT(hmm, dataTests[1+15*4:96:end], distributionForecastVector[1+15*4:96:end], "15:00")
            pit2100 = HMM_Forecast.plotPIT(hmm, dataTests[1+21*4:96:end], distributionForecastVector[1+21*4:96:end], "21:00")
            pitSpecificTimes = plot(pit0300, pit0900, pit01500, pit2100, layout=(2,2))
            png(pitYear, ".//HMM_Forecast//tmp//basismodel_hh($hh)//states($N)_pitYear.png")
            png(pitSpecificTimes, ".//HMM_Forecast//tmp//basismodel_hh($hh)//states($N)_pitSpecificTimes.png")
            png(pitSeasons, ".//HMM_Forecast//tmp//basismodel_hh($hh)//states($N)_pitSeasons.png")
            prevTime = printTimeAndResetTimeStamp(prevTime)

            # Calc average mean error
        end
    end