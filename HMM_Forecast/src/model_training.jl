# Function to run BasisModel runBasisModelAnalysis
using Random, Printf

function trainBasisModel(hh, discretTyp::String, numberOfObservationsVector::Vector{Int}, numberOfStatesVector = 30:5:60)
    iter = 100

    # Data
    originalObservations = readAndNormalizeData(hh)
    prevTime = now()
    
    for numberOfObservations in numberOfObservationsVector
        prevTime = printTimeAndResetTimeStamp(prevTime)
        (observationSpace, infoBins), observations, observationsAsIndeces = preprocessing(originalObservations, discretTyp, numberOfObservations)

        # Extract Trainigsdata
        dataTrainingAsIndeces  = observationsAsIndeces[dateIndeces[2,1]:dateIndeces[3,1]-1]

        for N in numberOfStatesVector
            # Train and store model 
            println("-------------- Train Basis Model with Discretization $discretTyp, $numberOfObservations Observations and $N states------------------")
            hmm, logliklihood_hmm = HMM_Forecast.runBWAlgoWithRandomInit((observationSpace, dataTrainingAsIndeces), N, iter);
            filename = @sprintf("basismodel_hh(%02d)_diskr(%c%03d)_states(%03d)", hh, discretTyp, numberOfObservations, N)
            saveHMM(hmm, "hyperparameter_analysis/"*filename)
            prevTime = printTimeAndResetTimeStamp(prevTime)
        end
    end
end

# ---------------------------------------------------------------------------
# Legacy Code


# function runSeasonModelFullYear(numberOfStatesVector = 50:150:250, hh = 1) 

#     Random.seed!(42)
    
#     iter = 100

#     # Data
#     (observationSpace, observations, observationsAsIndeces) = getData2Years_Seasonstamps(hh);
#     dates = dateTimesOf2YearsData()
#     dateIndeces = calcFirstQHofYearAndMonth()

#     startIndexTraining  = dateIndeces[2,1] 
#     endIndexTraining    = dateIndeces[3,1]-1
#     startIndexTest      = dateIndeces[3,1]
#     endIndexTest        = endOfDecember20()
#     indecesSpring20 = dateIndeces[3,3]:dateIndeces[3,6]-1
#     indecesSummer20 = dateIndeces[3,6]:dateIndeces[3,9]-1
#     indecesFall20   = dateIndeces[3,9]:dateIndeces[3,12]-1
#     indecesWinter20 = vcat(dateIndeces[3,1]:dateIndeces[3,3]-1, dateIndeces[3,12]:endIndexTest)
    
#     dataTrainingAsIndeces   = observationsAsIndeces[startIndexTraining:endIndexTraining]
#     dataTestAsIndeces       = observationsAsIndeces[startIndexTest:endIndexTest]
#     dataTraining            = observations[startIndexTraining:endIndexTraining]
#     dataTests               = observations[startIndexTest:endIndexTest]

#     prevTime = now()
#     carme = Dict()


#     for N in numberOfStatesVector
#         folderPath = "seasonmodel_hh($hh)//fullyear_states($N)//"

#         # Train and store model 
#         println("\n ########################### MODEL $N states #################################")
#         println("-------------- Train Model with $N states------------------")
#         hmm, logliklihood_hmm = HMM_Forecast.runBWAlgoWithRandomInit((observationSpace, dataTrainingAsIndeces), N, iter);
#         saveHMM(hmm, folderPath*"seasonmodelfull_states($N)")
#         # N = 50
#         # hmm1 = loadHMM("basismodel_hh(1)//states(1)//basismodel_states(1)")
#         prevTime = printTimeAndResetTimeStamp(prevTime)
        
#         # Calc Prediction
#         println("-------------- Calc forecast distribution for {$N} states------------------")
#         distributionForecastVector = createSeveralOneStepPredictions(hmm |> updateHMMNumericalStable, dataTrainingAsIndeces, dataTestAsIndeces)::Vector{Vector{Float64}}
#         prevTime = printTimeAndResetTimeStamp(prevTime)

#         # plotDistributionForecastWithViolin(hmm, dataTraining[end-20:end], dataTests[3301:3320], distributionForecastVector[1:20])
 
#         # Generate PIT Plots
#         println("-------------- Generate PT plots for {$N} states------------------")
#         pitYear = HMM_Forecast.plotPIT(hmm, dataTests, distributionForecastVector, "Season Model Full Year")
#         pitSpring = HMM_Forecast.plotPIT(hmm, observations[indecesSpring20], distributionForecastVector[indecesSpring20 .- (startIndexTest-1)], "Spring")
#         pitSummer = HMM_Forecast.plotPIT(hmm, observations[indecesSummer20], distributionForecastVector[indecesSummer20 .- (startIndexTest-1)], "Summer")
#         pitFall = HMM_Forecast.plotPIT(hmm, observations[indecesFall20], distributionForecastVector[indecesFall20 .- (startIndexTest-1)], "Fall")
#         pitWinter = HMM_Forecast.plotPIT(hmm, observations[indecesWinter20], distributionForecastVector[indecesWinter20 .- (startIndexTest-1)], "Winter")
#         pitSeasons = plot(pitSpring, pitSummer, pitFall, pitWinter, layout=(2,2))
#         pit0300 = HMM_Forecast.plotPIT(hmm, dataTests[1+3*4:96:end], distributionForecastVector[1+3*4:96:end], "03:00")
#         pit0900 = HMM_Forecast.plotPIT(hmm, dataTests[1+9*4:96:end], distributionForecastVector[1+9*4:96:end], "09:00")
#         pit01500 = HMM_Forecast.plotPIT(hmm, dataTests[1+15*4:96:end], distributionForecastVector[1+15*4:96:end], "15:00")
#         pit2100 = HMM_Forecast.plotPIT(hmm, dataTests[1+21*4:96:end], distributionForecastVector[1+21*4:96:end], "21:00")
#         pitSpecificTimes = plot(pit0300, pit0900, pit01500, pit2100, layout=(2,2))
#         png(pitYear, ".//HMM_Forecast//tmp//"*folderPath*"pitYear.png")
#         png(pitSpecificTimes, ".//HMM_Forecast//tmp//"*folderPath*"pitSpecificTimes.png")
#         png(pitSeasons, ".//HMM_Forecast//tmp//"*folderPath*"pitSeasons.png")
#         prevTime = printTimeAndResetTimeStamp(prevTime)

#         # Calc average mean error
#         push!(carme, N => calcAverageRelativeMeanError(observationSpace, dataTests, distributionForecastVector))
#     end

#     println(carme)
#     return carme
# end

# function runBasisModelAnalysis(numberOfStatesVector = 50:50:300, hh = 1)

#     Random.seed!(42)
    
#     iter = 50

#     # Data
#     (observationSpace, observations, observationsAsIndeces) = getData2Years(hh);
#     dates = dateTimesOf2YearsData()
#     dateIndeces = calcFirstQHofYearAndMonth()

#     startIndexTraining  = dateIndeces[2,1] 
#     endIndexTraining    = dateIndeces[3,1]-1
#     startIndexTest      = dateIndeces[3,1]
#     endIndexTest        = endOfDecember20()
#     indecesSpring20 = dateIndeces[3,3]:dateIndeces[3,6]-1
#     indecesSummer20 = dateIndeces[3,6]:dateIndeces[3,9]-1
#     indecesFall20   = dateIndeces[3,9]:dateIndeces[3,12]-1
#     indecesWinter20 = vcat(dateIndeces[3,1]:dateIndeces[3,3]-1, dateIndeces[3,12]:endIndexTest)
    
#     dataTrainingAsIndeces   = observationsAsIndeces[startIndexTraining:endIndexTraining]
#     dataTestAsIndeces       = observationsAsIndeces[startIndexTest:endIndexTest]
#     dataTraining            = observations[startIndexTraining:endIndexTraining]
#     dataTests               = observations[startIndexTest:endIndexTest]

#     prevTime = now()
#     loglike = Dict()

#     for N in numberOfStatesVector
#         # Train and store model 
#         println("\n ########################### MODEL $N states #################################")
#         println("-------------- Train Model with $N states------------------")
#         hmm, logliklihood_hmm = HMM_Forecast.runBWAlgoWithRandomInit((observationSpace, dataTrainingAsIndeces), N, iter);
#         saveHMM(hmm, "basismodel_hh($hh)//basismodel_states($N)")
#         # N = 50
#         # hmm1 = loadHMM("basismodel_hh(1)//states(1)//basismodel_states(1)")
#         prevTime = printTimeAndResetTimeStamp(prevTime)
        
#         # Calc Prediction
#         println("-------------- Calc forecast distribution for {$N} states------------------")
#         distributionForecastVector = createSeveralOneStepPredictions(hmm |> updateHMMNumericalStable, dataTrainingAsIndeces, dataTestAsIndeces)::Vector{Vector{Float64}}
#         prevTime = printTimeAndResetTimeStamp(prevTime)

#         # plotDistributionForecastWithViolin(hmm, dataTraining[end-20:end], dataTests[3301:3320], distributionForecastVector[1:20])
 
#         # # Generate PIT Plots
#         # println("-------------- Generate PT plots for {$N} states------------------")
#         # pitYear = HMM_Forecast.plotPIT(hmm, dataTests, distributionForecastVector, "PIT of Year 2020")
#         # pitSpring = HMM_Forecast.plotPIT(hmm, observations[indecesSpring20], distributionForecastVector[indecesSpring20 .- (startIndexTest-1)], "Spring")
#         # pitSummer = HMM_Forecast.plotPIT(hmm, observations[indecesSummer20], distributionForecastVector[indecesSummer20 .- (startIndexTest-1)], "Summer")
#         # pitFall = HMM_Forecast.plotPIT(hmm, observations[indecesFall20], distributionForecastVector[indecesFall20 .- (startIndexTest-1)], "Fall")
#         # pitWinter = HMM_Forecast.plotPIT(hmm, observations[indecesWinter20], distributionForecastVector[indecesWinter20 .- (startIndexTest-1)], "Winter")
#         # pitSeasons = plot(pitSpring, pitSummer, pitFall, pitWinter, layout=(2,2))
#         # pit0300 = HMM_Forecast.plotPIT(hmm, dataTests[1+3*4:96:end], distributionForecastVector[1+3*4:96:end], "03:00")
#         # pit0900 = HMM_Forecast.plotPIT(hmm, dataTests[1+9*4:96:end], distributionForecastVector[1+9*4:96:end], "09:00")
#         # pit01500 = HMM_Forecast.plotPIT(hmm, dataTests[1+15*4:96:end], distributionForecastVector[1+15*4:96:end], "15:00")
#         # pit2100 = HMM_Forecast.plotPIT(hmm, dataTests[1+21*4:96:end], distributionForecastVector[1+21*4:96:end], "21:00")
#         # pitSpecificTimes = plot(pit0300, pit0900, pit01500, pit2100, layout=(2,2))
#         # png(pitYear, ".//HMM_Forecast//tmp//basismodel_hh($hh)//states($N)//pitYear.png")
#         # png(pitSpecificTimes, ".//HMM_Forecast//tmp//basismodel_hh($hh)//states($N)//pitSpecificTimes.png")
#         # png(pitSeasons, ".//HMM_Forecast//tmp//basismodel_hh($hh)//states($N)//pitSeasons.png")
#         # prevTime = printTimeAndResetTimeStamp(prevTime)

#         # Calc average mean error
#         (loglikeTrain, loglikeTest) = (loglikelihood(hmm, dataTraining), loglikelihood(hmm |> updateHMMNumericalStable, dataTests))
#         println("LOGLIKE --- Train: $loglikeTrain / Test: $loglikeTest")
#         push!(loglike, N => (loglikeTrain, loglikeTest))
#     end

#     println(carme)
#     return loglike
# end

# function trainBasisModels(hh = 1, numberOfStatesVector = 30:5:60)
#     iter = 100

#     # Data
#     (observationSpace, observations, observationsAsIndeces) = getData2Years_Simplified(hh);
#     dateIndeces = calcFirstQHofYearAndMonth()

#     dataTrainingAsIndeces   = observationsAsIndeces[dateIndeces[2,1]:dateIndeces[3,1]-1]

#     prevTime = now()
#     for N in numberOfStatesVector
#         # Train and store model 
#         println("-------------- Train Basis Model with $N states------------------")
#         hmm, logliklihood_hmm = HMM_Forecast.runBWAlgoWithRandomInit((observationSpace, dataTrainingAsIndeces), N, iter);
#         saveHMM(hmm, "simplified_experiments/basismodel_hh($hh)//basismodel_states($N)")
#         prevTime = printTimeAndResetTimeStamp(prevTime)
#     end
# end

# function trainBasisModelsWithTimestamps(hh = 1, numberOfStatesVector = 30:5:60, numberOfTimeBlocks = 4 )
#     iter = 100

#     # Data
#     (observationSpace, observations, observationsAsIndeces) = getData2Years_SimplifiedAndTimestamps(hh, numberOfTimeBlocks);
#     dateIndeces = calcFirstQHofYearAndMonth()

#     dataTrainingAsIndeces  = observationsAsIndeces[dateIndeces[2,1]:dateIndeces[3,1]-1]

#     prevTime = now()
#     for N in numberOfStatesVector
#         # Train and store model 
#         println("-------------- Train Basis Model with timestamps $(numberOfTimeBlocks) with $N states------------------")
#         hmm, logliklihood_hmm = HMM_Forecast.runBWAlgoWithRandomInit((observationSpace, dataTrainingAsIndeces), N, iter);
#         saveHMM(hmm, "simplified_experiments/basismodel_timestamps_hh($hh)//basismodel_ts($numberOfTimeBlocks)_states($N)")
#         prevTime = printTimeAndResetTimeStamp(prevTime)
#     end
# end

# function trainSeasonModels(hh = 1, numberOfStatesVector = 30:5:60)
#     iter = 100

#     # Data
#     (observationSpace, observations, observationsAsIndeces) = getData2Years_Simplified(hh);

#     trainDataIndeces = [trainDataSpringIndeces, trainDataSummerIndeces, trainDataFallIndeces, trainDataWinterIndeces]

#     prevTime = now()
#     for seasonIndex in 1:4
#         dataTrainingAsIndeces   = observationsAsIndeces[trainDataIndeces[seasonIndex]]
#         for N in numberOfStatesVector
#             # Train and store model 
#             println("-------------- Train Season Model $(seasonStrings[seasonIndex]) with $N states------------------")
#             hmm, logliklihood_hmm = HMM_Forecast.runBWAlgoWithRandomInit((observationSpace, dataTrainingAsIndeces), N, iter);
#             saveHMM(hmm, "simplified_experiments/seasonmodel_hh($hh)//seasonmodel_"*seasonStrings[seasonIndex]*"_states($N)")
#             prevTime = printTimeAndResetTimeStamp(prevTime)
#         end
#     end
# end

# function trainSeasonModelsWithTimeStamps(hh = 1, numberOfStatesVector = 30:5:60, numberOfTimeBlocks = 4)
#     iter = 100

#     # Data
#     (observationSpace, observations, observationsAsIndeces) = getData2Years_SimplifiedAndTimestamps(hh, numberOfTimeBlocks);
#     trainDataIndeces = [trainDataSpringIndeces, trainDataSummerIndeces, trainDataFallIndeces, trainDataWinterIndeces]

#     prevTime = now()
#     for seasonIndex in 1:4
#         dataTrainingAsIndeces   = observationsAsIndeces[trainDataIndeces[seasonIndex]]
#         for N in numberOfStatesVector
#             # Train and store model 
#             println("-------------- Train Season Timestamp ($numberOfTimeBlocks) Model $(seasonStrings[seasonIndex]) with $N states------------------")
#             hmm, logliklihood_hmm = HMM_Forecast.runBWAlgoWithRandomInit((observationSpace, dataTrainingAsIndeces), N, iter);
#             saveHMM(hmm, "simplified_experiments/seasonmodel_timestamps_hh($hh)//seasonmodel_ts_"*seasonStrings[seasonIndex]*"_states($N)_timeblocks($numberOfTimeBlocks)")
#             prevTime = printTimeAndResetTimeStamp(prevTime)
#         end
#     end
# end

# function trainAllModels(hhVector, numberOfStatesVector, numberOfTimeBlocksVector)
#     for hh in hhVector
#         #trainBasisModels(hh, numberOfStatesVector)
#         #trainSeasonModels(hh, numberOfStatesVector)
#         for numberOfTimeBlocks in numberOfTimeBlocksVector
#             trainBasisModelsWithTimestamps(hh, numberOfStatesVector, numberOfTimeBlocks)
#             #trainSeasonModelsWithTimeStamps(hh, numberOfStatesVector, numberOfTimeBlocks)
#         end
#     end
#     println("#################################################################################")
#     println("#################################################################################")
#     println("#################################################################################")
#     println("#################################################################################")
#     println("###################### EXPERIMENTS FINISHED #####################################")
# end



