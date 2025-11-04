# Function to run BasisModel runBasisModelAnalysis
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Plots
using HMM_Forecast


optimalModels = [
    (1, "A", 40, 100)
    (2, "A", 30, 100)
    (3, "A", 50, 50)
    (4, "A", 60, 100)
    (5, "A", 40, 100)
    (1, "B", 80, 100)
    (2, "B", 40, 100)
    (3, "B", 50, 100)
    (4, "B", 50, 100)
    (5, "B", 80, 100)
]

pitHist = Array{Any}(undef, 5)

######## PIT PLOTS
for (hh, discretType, numberOfStates, numberOfObservations) in optimalModels   
    # PIT Histograms
    HMM_Forecast.plotPITHistogramYear(hh,discretType, numberOfObservations, numberOfStates) |> display
    # HMM_Forecast.plotPITHistogramDaytime(hh,discretType, numberOfObservations, numberOfStates) |> display
end

# Parameters
hh = 5
numberOfObservations =  100
numberOfStates = 50
discretType = "A"

# PIT Histograms
HMM_Forecast.plotPITHistogramDaytime(hh,discretType, numberOfObservations, numberOfStates)


############## Plot Violinplots
timeinstance = 436
T = 10
H = 15
(hh, discretType, numberOfStates, numberOfObservations) = optimalModels[8]
savefig( HMM_Forecast.plotExampleViolinForecastforBasismodel(hh, discretType, numberOfObservations, numberOfStates, timeinstance,T,  H), pwd() )

for timeinstance in 441:445
    HMM_Forecast.plotExampleViolinForecastforBasismodel(hh, discretType, numberOfObservations, numberOfStates, timeinstance,T,  H) |> display
end

#####################################################################
## Plot convergence point histogram
T = 20
H = 200

for (hh, discretType, numberOfStates, numberOfObservations) in optimalModels   
    HMM_Forecast.plotConvergencePointsHistogram(hh, discretType, numberOfObservations, numberOfStates, T,  H, 0.01) |> display
    HMM_Forecast.plotConvergencePointsHistogram(hh, discretType, numberOfObservations, numberOfStates, T,  H, 0.1) |> display
end