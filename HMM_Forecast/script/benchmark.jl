## Pkg
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise
using HMM_Forecast

# @Antonio: Zuerst diese Zeile ausführen um zu testen ob Code grundsätzlich läuft. Wenn es läuft, einfach löschen.
HMM_Forecast.TEST_trainLinearQR(1)

# @Antionio: Dann unteren Code mit Strg+/ auskommentieren und durchlaufen lassen. Rechnet wsl 2 Tage. 

# hhs = 1:5
# for hh in hhs
#     HMM_Forecast.trainLinearQR(hh)
# end

# println("\n ------------------ FINISH ---------------------")