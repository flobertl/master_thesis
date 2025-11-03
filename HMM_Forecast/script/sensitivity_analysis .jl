# Function to run BasisModel runBasisModelAnalysis
using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, Dates, Statistics, Random, Plots
using HMM_Forecast

historicWindowLengthVector = [1,2,  3, 5, 10, 25, 50, 100, 200]

optimalModels = [
    (1, "A", 40, 100)
    (1, "B", 80, 100)
    (2, "A", 30, 100)
    (2, "B", 40, 100)
    (3, "A", 50, 50)
    (4, "A", 60, 100)
    (4, "B", 50, 100)
    (5, "A", 40, 100)
    (5, "B", 80, 100)
]

for (hh, disType, N, M) in optimalModels
    println("Running sensitivity analysis for basismodel_hh($hh)_diskr($disType$M)_states($N)")
    # Run evaluation
    #HMM_Forecast.sensitivityAnalysisForSpecificModel(hh, disType, M, N, historicWindowLengthVector)

    # # Plot results
    HMM_Forecast.plotSensitvityAnalysis(hh, historicWindowLengthVector)
end

