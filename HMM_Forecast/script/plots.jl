# Function to run BasisModel runBasisModelAnalysis
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics, Random, Plots
using HMM_Forecast

# Parameters
hh = 1
numberOfObservations =  100
numberOfStates = 40
discretType = "A"

# PIT Histograms
HMM_Forecast.plotPITforBasismodel(hh,discretType, numberOfObservations, numberOfStates)

# Artificial PIT Histograms
HMM_Forecast.artificialPITHistogram("pit_histogram_overdispersed")
