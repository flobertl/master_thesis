# Function to run BasisModel runBasisModelAnalysis
using Random

function generatePITforSeasonModels(hmm::HMM, trainData, testData, folderPath::String, name = "")
    trainDataAsIndeces = translateObservationsToIndex(trainData, hmm.observationSpace)
    testDataAsIndeces = translateObservationsToIndex(testData, hmm.observationSpace)

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
    trainDataAsIndeces = translateObservationsToIndex(trainData, hmm.observationSpace)
    testDataAsIndeces = translateObservationsToIndex(testData, hmm.observationSpace)

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

function calcEvaluation(hmm::HMM, trainData, testData)
    testDataAsIndeces = translateObservationsToIndex(testData, hmm.observationSpace)
    trainDataAsIndeces = translateObservationsToIndex(trainData, hmm.observationSpace)
    hmmStable = hmm |> updateHMMNumericalStable

    # Calc Prediction
    distributionForecastVector = createSeveralOneStepPredictions(hmmStable, trainDataAsIndeces, testDataAsIndeces)::Vector{Vector{Float64}}

    # Calc Likelihood
    loglikelihood_train = loglikelihood(hmmStable, trainData)
    loglikelihood_test = loglikelihood(hmmStable, testData)

    # Calc MAPE 
    mape = mae_forMeanPointForecast(hmm.observationSpace, testData, distributionForecastVector)

    # Calc R_squared
    r_sqare = 0 #r_squared_forMeanPointForecast(hmm.observationSpace, testData, distributionForecastVector)

    # Calc CRPS
    crps = meanCRPS(hmm.observationSpace, testData, distributionForecastVector)

    return ((loglikelihood_test,loglikelihood_train), mape, r_sqare, crps)
end

function calcEvaluationTimestampModel(hmmTS::HMM, trainDataTS, testDataTS,  obserSpaceOriginal, testDataOriginal)
    testDataAsIndeces = translateObservationsToIndex(testDataTS, hmmTS.observationSpace)
    trainDataAsIndeces = translateObservationsToIndex(trainDataTS, hmmTS.observationSpace)
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

function printEvaluation(name::String, ((loglikelihood_test,loglikelihood_train), mape, r_sqare, crps))
    println("$name --- loglike-Train: $loglikelihood_train /// loglike-Test: $loglikelihood_test /// MAE: $mape /// Mean CRPS: $crps")
end

function calcEvaluationGivenForecast(observationSpace::ObservationSpace, testData, distributionForecastVector)
    # Calc MAPE 
    mape = mae_forMeanPointForecast(observationSpace, testData, distributionForecastVector)
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
            result = calcEvaluation(hmm, dataTraining, dataTest)
            push!(resultSeason, result)
            printEvaluation("seasonmodel_($hh)_"*seasonStrings[seasonIndex]*"_states($N)" , result)
        end
        results[seasonIndex] = resultSeason
        println(" ")
    end
    prevTime = printTimeAndResetTimeStamp(prevTime)
    return results
end


function evaluateBasismodel(hh = 1, numberOfStatesVector = 30:5:60)
    # Data
    (observationSpaceOriginal, observations, observationsAsIndecesOriginal) = getData2Years_Simplified(hh);
    dateIndeces = calcFirstQHofYearAndMonth()

    dataTraining = observations[dateIndeces[2,1]:dateIndeces[3,1]-1]
    dataTest     = observations[dateIndeces[3,1]:endOfDecember20()]

    prevTime = now()
    results = []
    println("------------------ Evaluate basismodel_hh($hh) --------------------")
    for N in numberOfStatesVector
        # Train and store model 
        hmm = loadHMM("simplified_experiments/basismodel_hh($hh)//basismodel_states($N)") 
        result = calcEvaluation(hmm, dataTraining, dataTest)
        push!(results, result)
        printEvaluation("basismodel_hh($hh)_states($N)" , result)
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