module Plot

using Plots
using Main.HMM.Types, Main.HMM.Data

export plotHist, plotForecast

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

end