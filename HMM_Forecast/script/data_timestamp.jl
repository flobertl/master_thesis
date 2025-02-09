(observationSpace, observations, observationsAsIndeces) = HMM_Forecast.getData2Years_Timestamps(hh, 8);
dates = HMM_Forecast.dateTimesOf2YearsData()
dateIndeces = HMM_Forecast.calcFirstQHofYearAndMonth()

startIndexTraining  = dateIndeces[2,1] 
endIndexTraining    = dateIndeces[3,1]-1
startIndexTest      = dateIndeces[3,1]
endIndexTest        = HMM_Forecast.endOfDecember20()
indecesSpring20 = dateIndeces[3,3]:dateIndeces[3,6]-1
indecesSummer20 = dateIndeces[3,6]:dateIndeces[3,9]-1
indecesFall20   = dateIndeces[3,9]:dateIndeces[3,12]-1
indecesWinter20 = vcat(dateIndeces[3,1]:dateIndeces[3,3]-1, dateIndeces[3,12]:endIndexTest)


dataTrainingAsIndeces   = observationsAsIndeces[startIndexTraining:endIndexTraining]
dataTestAsIndeces       = observationsAsIndeces[startIndexTest:endIndexTest]
dataTrainingFullYear            = observations[startIndexTraining:endIndexTraining]
dataTestsFullYear               = observations[startIndexTest:endIndexTest]

# Season Data
trainDataFall = observations[dateIndeces[2, 9] : (dateIndeces[2, 12] - 1)]
testDataFall  = observations[dateIndeces[3, 9] : (dateIndeces[3, 12] - 1)]
trainDataWinter = observations[dateIndeces[1, 12] : (dateIndeces[2, 3] - 1)]
testDataWinter = observations[dateIndeces[2, 12] : (dateIndeces[3, 3] - 1)]
trainDataSpring = observations[dateIndeces[2, 3] : (dateIndeces[2, 6] - 1)]
testDataSpring = observations[dateIndeces[3, 3] : (dateIndeces[3, 6] - 1)]
trainDataSummer = observations[dateIndeces[2, 6] : (dateIndeces[2, 9] - 1)]
testDataSummer = observations[dateIndeces[3, 6] : (dateIndeces[3, 9] - 1)]
