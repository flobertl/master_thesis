# Function to run BasisModel runBasisModelAnalysis
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics, Random, Plots
using HMM_Forecast

numberOfStatesVector = [1] #30:10:70

# HMM_Forecast.runBasisModelAnalysis(numberOfStatesVector, 2)

HMM_Forecast.trainSeasonModels(numberOfStatesVector, 2)
