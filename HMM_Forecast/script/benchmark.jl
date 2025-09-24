## Pkg
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, ChangePrecision, Dates, Plots
using HMM_Forecasts

hhs = 1:5

for hh in hhs
    HMM_Forecast.trainLinearQR(hh)
end

println("\n ------------------ FINISH ---------------------")