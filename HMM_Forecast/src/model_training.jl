# Function to run BasisModel runBasisModelAnalysis
using Random

function runSeasonModelFullYear(numberOfStatesVector = 50:150:250, hh = 1) 

    Random.seed!(42)
    
    iter = 100

    # Data
    (observationSpace, observations, observationsAsIndeces) = getData2Years_Seasonstamps(hh);
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
    carme = Dict()


    for N in numberOfStatesVector
        folderPath = "seasonmodel_hh($hh)//fullyear_states($N)//"

        # Train and store model 
        println("\n ########################### MODEL $N states #################################")
        println("-------------- Train Model with $N states------------------")
        hmm, logliklihood_hmm = HMM_Forecast.runBWAlgoWithRandomInit((observationSpace, dataTrainingAsIndeces), N, iter);
        saveHMM(hmm, folderPath*"seasonmodelfull_states($N)")
        # N = 50
        # hmm1 = loadHMM("basismodel_hh(1)//states(1)//basismodel_states(1)")
        prevTime = printTimeAndResetTimeStamp(prevTime)
        
        # Calc Prediction
        println("-------------- Calc forecast distribution for {$N} states------------------")
        distributionForecastVector = createSeveralOneStepPredictions(hmm |> updateHMMNumericalStable, dataTrainingAsIndeces, dataTestAsIndeces)::Vector{Vector{Float64}}
        prevTime = printTimeAndResetTimeStamp(prevTime)

        # plotDistributionForecastWithViolin(hmm, dataTraining[end-20:end], dataTests[3301:3320], distributionForecastVector[1:20])
 
        # Generate PIT Plots
        println("-------------- Generate PT plots for {$N} states------------------")
        pitYear = HMM_Forecast.plotPIT(hmm, dataTests, distributionForecastVector, "Season Model Full Year")
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
        png(pitYear, ".//HMM_Forecast//tmp//"*folderPath*"pitYear.png")
        png(pitSpecificTimes, ".//HMM_Forecast//tmp//"*folderPath*"pitSpecificTimes.png")
        png(pitSeasons, ".//HMM_Forecast//tmp//"*folderPath*"pitSeasons.png")
        prevTime = printTimeAndResetTimeStamp(prevTime)

        # Calc average mean error
        push!(carme, N => calcAverageRelativeMeanError(observationSpace, dataTests, distributionForecastVector))
    end

    println(carme)
    return carme
end

function runBasisModelAnalysis(numberOfStatesVector = 50:50:300, hh = 1) 

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
    carme = Dict()

    for N in numberOfStatesVector
        # Train and store model 
        println("\n ########################### MODEL $N states #################################")
        println("-------------- Train Model with $N states------------------")
        hmm, logliklihood_hmm = HMM_Forecast.runBWAlgoWithRandomInit((observationSpace, dataTrainingAsIndeces), N, iter);
        saveHMM(hmm, "basismodel_hh($hh)//states($N)//basismodel_states($N)")
        # N = 50
        # hmm1 = loadHMM("basismodel_hh(1)//states(1)//basismodel_states(1)")
        prevTime = printTimeAndResetTimeStamp(prevTime)
        
        # Calc Prediction
        println("-------------- Calc forecast distribution for {$N} states------------------")
        distributionForecastVector = createSeveralOneStepPredictions(hmm |> updateHMMNumericalStable, dataTrainingAsIndeces, dataTestAsIndeces)::Vector{Vector{Float64}}
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
        png(pitYear, ".//HMM_Forecast//tmp//basismodel_hh($hh)//states($N)//pitYear.png")
        png(pitSpecificTimes, ".//HMM_Forecast//tmp//basismodel_hh($hh)//states($N)//pitSpecificTimes.png")
        png(pitSeasons, ".//HMM_Forecast//tmp//basismodel_hh($hh)//states($N)//pitSeasons.png")
        prevTime = printTimeAndResetTimeStamp(prevTime)

        # Calc average mean error
        push!(carme, N => mape_forMeanPointForecast(observationSpace, dataTests, distributionForecastVector))
    end

    println(carme)
    return carme
end