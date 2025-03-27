using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, ChangePrecision, Plots
using HMM_Forecast

using Plots, QuantEcon

P = [0.4 0.6; 0.2 0.8];
mc = MarkovChain(P);
stationary_distributions(mc)