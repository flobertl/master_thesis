using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, ChangePrecision, Plots
using HMM_Forecast

using Plots

# Beispiel-Daten
# Zeilen = Anzahl Zustände, Spalten = Fensterlängen
states = [2, 4, 6, 8, 10]  # x-Achse
historicWindow = [1, 3, 5]   # verschiedenfarbige Linien
mae_tabelle = [
    0.9  0.8  0.7;
    0.85 0.75 0.65;
    0.83 0.73 0.63;
    0.8  0.7  0.6;
    0.78 0.68 0.58
]

HMM_Forecast.plotMAE(mae_tabelle, states, historicWindow)