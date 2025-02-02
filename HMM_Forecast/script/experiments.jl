using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, ChangePrecision
using HMM_Forecast

@changeprecision Float32 begin
# Load data and model
    hh = 1
    states = 50:50:200

    HMM_Forecast.runBasisModelAnalysis(states, hh)
end

p = plot(states, sin.(states), label="sin(states)")  # Erstes Element mit Legende
png(".//HMM_Forecast//tmp//basismodel_hh($hh)//states(1)//pitYear.png")
