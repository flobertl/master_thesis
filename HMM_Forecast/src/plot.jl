using Plots, StatsPlots

function plotHist(historyData)
    N = length(historyData)
    x = 1:N

    p = plot(x, historyData, label= "observations") 
    plot!(p, legend=:outerbottom, legendcolumns=3)
    title!(p, "Historical Data")
    xlabel!(p,"time")
    ylabel!(p, "MWh")

    return p
end

function plotForecast(historyData, forecastData)
    T = length(historyData)
    window = T-100:T
    T_hat = length(forecastData)
    historical_dates = 1:T
    forecast_dates = T+1 : (T + T_hat)

    p = plot(
        historical_dates[window], historyData[window],
        label="Historical Load",
        color=:blue,
        lw=2,
        xlabel="Date",
        ylabel="Load (MW)",
        legend=:topright,
        title="Load Forecast with Historical Data"
    )
    plot!(p, 
        forecast_dates, forecastData,
        label="Forecast Load",
        color=:red,
        lw=2,
        linestyle=:dash
    )

    # # Highlight forecast region
    # highlight_area_start = last(historical_dates)
    # highlight_area_end = last(forecast_dates)
    # plot!(
    #     [highlight_area_start, highlight_area_end],
    #     [minimum(loads), minimum(loads)],
    #     color=:gray,
    #     alpha=0.2,
    #     lw=0,
    #     fill_between=(highlight_area_start, highlight_area_end),
    #     label=""
    # )
    

    return p
end

function plotForecastSlidingWindow(hmm::HMM, observations, forecastHorizon::Int, firstIndexToPlot::Int)
    # Set Parameters
    T = length(observations)
    indeces = firstIndexToPlot:T
    observationsAsIndeces = translateObservationsToIndex(observations, hmm.observationSpace)

    # Create Base Plot
    p = plot(
        indeces, observations[indeces],
        color=:black,
        lw=2,
        xlabel="Index",
        ylabel="Observation",
        title="Sliding Window Forecast (Best Path)"
    )

    # Add Forecastlines
    for i in indeces 
        indexForecast = i:(i + forecastHorizon)
        forecastAsIndeces, likelihood_forecast = bestPathPrognosis(hmm, observationsAsIndeces[1:i], forecastHorizon)
        forecast = translateIndexToObservations(forecastAsIndeces, hmm.observationSpace)

        startPointWithForecast = [observations[i]; forecast]
        
        colors = [RGBA(0, 0.0, 1, alpha) for alpha in LinRange(0.5, 0.2, (forecastHorizon+1))]

        plot!(p, 
            indexForecast, startPointWithForecast,
            color=colors,
            lw=2,
        )
    end

    return p
end

function plotDistributionForecastWithViolin(hmm::HMM, observationHist, observationFuture, distributionForecast::Vector{Vector{Float64}})
    T = length(observationHist)
    H = length(observationFuture)

    # Plot historical data
    p = plot(collect(1:T), observationHist, label= "historical observations", legend=false) 

    # Plot distribution via violin plots
    for i in 1:H
        frequency_i = transformDistributionVectorToFrequencyVector(hmm.observationSpace, distributionForecast[i])
        violin!(p, [i+T], frequency_i, color=:lightcyan2)
    end
    if H < 25 
        plot!(p, T:T+H, vcat([observationHist[end]], observationFuture), color = :red )
    else
        plot!(p, T:T+H, vcat([observationHist[end]], observationFuture), color = :black )
    end
    return p
end

function plotPIT(hmm::HMM, observationFuture::Vector{Int}, distributionForecast::Vector{Vector{Float64}}, header = "")
    N = length(distributionForecast)
    quantiles = zeros(Float64, N)
    for t in 1:N
        f(x) = x<= observationFuture[t]
        frequencyVector =  transformDistributionVectorToFrequencyVector(hmm.observationSpace, distributionForecast[t])
        quantiles[t] = count(f, frequencyVector)/length(frequencyVector)
    end
    histogram(quantiles, title = header, legend = false)
end