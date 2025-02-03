(observationSpace, observations, observationsAsIndeces) = HMM_Forecast.getData2Years(hh);
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
dataTraining            = observations[startIndexTraining:endIndexTraining]
dataTests               = observations[startIndexTest:endIndexTest]