# Script to analyse the historical data
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics
using HMM_Forecast
using Plots

# Set Paramets
hhs = 1:5 
day = 96
week = 7


# load Data 2 Months
dateTimes = HMM_Forecast.dateTimesOf2YearsData()

# Plot daily development
function plotDailyDemandStatsByOneInterval(observations, (startIndex, endIndex),  header = "")
    T1 = (endIndex - startIndex +1)/(4*24) |> Int
    dayTimes1 = Dates.Time.(dateTimes[startIndex:startIndex+day-1])
    dayTimesStrings = map(dt -> Dates.format(dt, "HH:MM"), dayTimes1)

    # Calc the average of a daily demand profile over T Days
    averageDay = zeros(Float64, day)
    for i in 1:day
        averageDay[i] += observations[((i-1)+startIndex) : 96 : endIndex] |> sum

    end
    averageDay = averageDay/T1

    medi = zeros(Float32, day)
    for i in 1:day
        medi[i] += Statistics.median(observations[((i-1)+startIndex) : 96 : endIndex])
    end


    # Print default
    plot1 = plot(dayTimesStrings, averageDay, 
                color = :green, 
                legend = true, 
                framestyle = :box,
                grid = true,
                label = "", 
                ylims = (0,0.4), 
                #xticks = dayTimesStrings[1:12:96], 
                title = header,
                dpi = 300)
    # Add the days
    for i in 1:T1
        plot!(plot1, dayTimesStrings, observations[(i-1)*day+startIndex : (i*day+startIndex-1)], color =:lightcyan2, legend = false, label = "")
    end
    # # Add varianz
    standardDev = zeros(Float32, 96)
    for i in 0:95
        standardDev[i+1] = Statistics.std(observations[i .+ (startIndex:96:endIndex)])
    end

    plot!(plot1, dayTimesStrings, observations[startIndex : (day+startIndex-1)], color =:lightcyan2, label = "true days")
    plot!(plot1, dayTimesStrings, averageDay, color =:green, legend = true, label = "mean")
    plot!(plot1, dayTimesStrings, medi, color =:black, legend = true, label = "median")
    # plot!(plot1, dayTimesStrings, averageDay .- standardDev, color = :red, label = "standard deviation")
    plot!(plot1, dayTimesStrings, averageDay .+ standardDev, color = :red, label = "standard deviation")
    plot1
end

observations = HMM_Forecast.readAndNormalizeData(1)
for (season, dates) in HMM_Forecast.seasons
    println(season)
    plt = plotDailyDemandStatsByOneInterval(observations, (dates), season)
    savefig(plt, "Thesis Script\\plots\\observation_analysis\\"*season)
end
