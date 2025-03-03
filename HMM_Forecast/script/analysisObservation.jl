# Script to analyse the historical data
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics
using HMM_Forecast
using Plots

# Set Paramets
hh = 3
day = 96
week = 7


# load Data 2 Months
(observationSpace, observations, observationsAsIndeces) = HMM_Forecast.getData2Years_Timestamps(hh, 8);
histogram(observations, legend = false, ylim = (0,500), color = "black")
dateTimes = HMM_Forecast.dateTimesOf2YearsData()
startJuni18 = 4*(24+15)+2 
startSeptember18 = startJuni18 + 24*4*92
startDezember18 = startSeptember18 + 24*4*91
startMärz19 = startDezember18 + 24*4*90
startJuni19 = startMärz19 + 24*4*92
startSeptember19 = startJuni19 + 24*4*92
startDezember19 = startSeptember19 + 24*4*91
startMärz20 = startDezember19 + 24*4*91
startJuni20 = startMärz20 + 24*4*92
startSeptember20 = startJuni20 + 24*4*92
startDezember20 = startSeptember20 + 24*4*91

seasonsByYear = Dict(
    "Sommer18" => (startJuni18,startSeptember18-1),
    "Sommer19" => (startJuni19,startSeptember19-1),
    "Sommer20" => (startJuni20,startSeptember20-1),
    "Herbst18" => (startSeptember18,startDezember18-1),
    "Herbst19" => (startSeptember19,startDezember19-1),
    "Herbst20" => (startSeptember20,startDezember20-1),
    "Frühling19" => (startMärz19,startJuni19-1),
    "Frühling20" => (startMärz20,startJuni20-1),
    "Winter18" => (startDezember18,startMärz19-1),
    "Winter19" => (startDezember19,startMärz20-1)
    )

seasons = Dict(
    "Sommer"    => ((startJuni18,startSeptember18-1),    (startJuni19,startSeptember19-1)),
    "Herbst"    => ((startSeptember18,startDezember18-1),(startSeptember19,startDezember19-1)),
    "Frühling"  => ((startMärz19,startJuni19-1),         (startMärz20,startJuni20-1)),
    "Winter"    => ((startDezember18,startMärz19-1),     (startDezember19,startMärz20-1))
    )


# Plot daily development
function plotDailyDemandStatsByOneInterval((startIndex, endIndex),  header = "")
    T1 = (endIndex - startIndex +1)/(4*24) |> Int
    dayTimes1 = Dates.Time.(dateTimes[startIndex:startIndex+day-1])

    # Calc the average of a daily demand profile over T Days
    averageDay = zeros(Float64, day)
    for i in 1:day
        averageDay[i] += observations[((i-1)+startIndex) : 96 : endIndex] |> sum

    end
    averageDay = averageDay/T1

    medi = zeros(Int64, day)
    for i in 1:day
        medi[i] += Statistics.median(observations[((i-1)+startIndex) : 96 : endIndex])
    end


    # Print default
    plot1 = plot(dayTimes1, averageDay, 
                color =:black, 
                legend = true, 
                label = "average", 
                ylims = (0,2000), 
                xticks = dayTimes1[1:16:96], 
                title = header)
    # Add the days
    for i in 1:T1
        plot!(plot1, dayTimes1, observations[(i-1)*day+startIndex : (i*day+startIndex-1)], color =:lightcyan2, legend = false)
    end
    # Add varianz
    standardDev = zeros(Float64, 96)
    for i in 0:95
        standardDev[i+1] = Statistics.std(observations[i .+ (startIndex:96:endIndex)])
    end

    plot!(plot1, dayTimes1, averageDay, color =:black, legend = false)
    plot!(plot1, dayTimes1, medi, color =:black, legend = false)
    plot!(plot1, dayTimes1, averageDay .- standardDev, color =:red)
    plot!(plot1, dayTimes1, averageDay .+ standardDev, color =:red)
    plot1
end

plotDailyDemandStatsByOneInterval((startDezember19, startMärz20 -1), "Spass")

for (season, dates) in seasonsByYear
    println(season)
    display(plotDailyDemandStatsByOneInterval((dates), season)) 
end

function plotDailyDemandStatsByTwoIntervals(((startIndex1, endIndex1), (startIndex2, endIndex2)),  header = "")
    # header = "Test"
    # (startIndex1, endIndex1) = (startDezember19, startMärz20 -1)
    # (startIndex2, endIndex2) = (startDezember18, startMärz19 -1)
    T1 = (endIndex1 - startIndex1 + 1)/(4*24) |> Int
    T2 = (endIndex2 - startIndex2 + 1)/(4*24) |> Int
    T = T1 + T2

    dayTimes = Dates.Time.(dateTimes[startIndex1:startIndex1+day-1])

    # Calc the average of a daily demand profile over T Days
    averageDay = zeros(Float64, day)
    for i in 1:day
        averageDay[i] += observations[((i-1)+startIndex1) : 96 : endIndex1] |> sum
        averageDay[i] += observations[((i-1)+startIndex2) : 96 : endIndex2] |> sum
    end
    averageDay = averageDay/T

    medi = zeros(Int64, day)
    for i in 1:day
        medi[i] += Statistics.median(observations[vcat(((i-1)+startIndex1) : 96 : endIndex1, ((i-1)+startIndex2) : 96 : endIndex2 )])
    end

    # Create default plot
    plot1 = plot(dayTimes, averageDay, 
                color =:green, 
                legend = true, 
                label = "mean", 
                ylims = (0,2000), 
                xticks = dayTimes[1:12:96], 
                title = header)
    plot1
    # Add the days
    for i in 1:T1
        plot!(plot1, dayTimes, observations[(i-1)*day+startIndex1 : (i*day+startIndex1-1)], color =:lightcyan1, label="")
    end
    for i in 1:T2
        plot!(plot1, dayTimes, observations[(i-1)*day+startIndex2 : (i*day+startIndex2-1)], color =:lightcyan2, label="")
    end
    plot1
    # Add varianz
    standardDev = zeros(Float64, 96)
    for i in 1:day
        standardDev[i] = Statistics.std(observations[vcat(((i-1)+startIndex1) : 96 : endIndex1, ((i-1)+startIndex2) : 96 : endIndex2)])
    end

    plot!(plot1, dayTimes, averageDay, color =:green, legend = true, label = "")
    plot!(plot1, dayTimes, medi, color =:black, legend = true, label = "median")
    plot!(plot1, dayTimes, averageDay .- standardDev, color = :red, label = "standard deviation")
    plot!(plot1, dayTimes, averageDay .+ standardDev, color = :red, label = "")
end

for (season, (dates1, dates2)) in seasons
    println(season)
    display(plotDailyDemandStatsByTwoIntervals((dates1, dates2), season)) 
end

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

x=1:10
p = plot(x, sin.(x), label="sin(x)")  # Erstes Element mit Legende
plot!(p, x, cos.(x), label="")        # Zweites Element ohne Legende
plot!(p, x, tan.(x), label="tan(x)")  # Drittes Element mit Legende

