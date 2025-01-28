# Script to analyse the historical data
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics
using HMM_Forecast
using Plots

# Set Paramets
hh = 2
day = 96
week = 7
X = 10
T = week * 10


# load Data 2 Months
(observationSpace, observations, observationsAsIndeces) = HMM_Forecast.getData2Years_Timestamps(hh, 8);
dateTimes = HMM_Forecast.dateTimesOf2YearsData()
startJuni18 = 4*(24+15)+2 
startSeptember18 = startJuni18 + 24*4*92
startDezember18 = startSeptember18 + 24*4*91
startMärz19 = startDezember18 + 24*4*90

# Plot daily development
startIndex = startDezember18
endIndex =  startMärz19 -1
T = (endIndex - startIndex +1)/(4*24) |> Int

# Calc the average of a daily demand profile over T Days
average = zeros(Float64, day)
for i in 1:T
    average += observations[(i-1)*day+startIndex : (i*day + startIndex -1)]
end
average = average/T

# Print average daily demand


plot1 = plot(dateTimes[startIndex:startIndex+day-1], average, color =:black, legend = false)
# Add the days
for i in 1:T
    plot!(plot1, dateTimes[startIndex:(startIndex+day-1)], observations[(i-1)*day+startIndex : (i*day+startIndex-1)], color =:lightcyan2)
end
# Add varianz
standardDev = zeros(Float64, 96)
for i in 0:95
    standardDev[i+1] = Statistics.std(observations[i .+ (startIndex:96:endIndex)])
end

plot!(plot1, dateTimes[startIndex:(startIndex+day-1)], average, color =:black, legend = false)
plot!(plot1, dateTimes[startIndex:(startIndex+day-1)], average .- standardDev, color =:red)
plot!(plot1, dateTimes[startIndex:(startIndex+day-1)], average .+ standardDev, color =:red)
plot1


# Plotting Experiments
violin(observations, ylims = (0,6000))
totalWeeks = 50
agregated = zeros(Float64, T)
for i in 1:totalWeeks
    observations = HMM_Forecast.translateIndexToObservations(observationsAsIndeces[W*i+1:T+W*i], observationSpace)
    agregated = agregated .+ (observations./totalWeeks)
end

plot1 = plot(dateTimes[1:T], agregated)
plot!(dateTimes[1:T], observations[1:T], color = :red)

