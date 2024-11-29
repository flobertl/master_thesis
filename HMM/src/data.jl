module Data

using Main.HMM.Types, Main.HMM.Helpers
using XLSX

export loadObservations2, loadObservations1 , discretize, getTestData2Month, getTestDataDay

function loadObservations1(path::String)
    # Öffnen einer Excel-Datei
    xf = XLSX.readxlsx(path)
    sh = xf["UserCustom"] 
    data = sh["B3:B100"] |> vec
        
    return(data)
end

function loadObservations2(path::String)
    # Öffnen einer Excel-Datei
    xf = XLSX.readxlsx(path)
    sh = xf["sers"] 
    data = sh["B1:B5000"] |> vec
        
    return(data)
end


function discretize(observations)
    discreteObs = map(round, observations)
    return map(Int, discreteObs)
end

function getTestDataDay()
    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/PV_2024_09_22.xlsx"
    observations = loadObservations1(path)

    # Convert Data
    discreteObser = discretize(observations)
    observationSpace = Set(discreteObser) |> ObservationSpace
    observationsAsIndeces = translateObservationsToIndex(discreteObser, observationSpace)

    return(observationSpace, observationsAsIndeces)
end

function getTestData2Month()
    # Load Data
    path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/verbrauch_schimek_okt_nov.xlsx"
    observations = loadObservations2(path)

    # Convert Data
    discreteObser = discretize(observations)
    observationSpace = Set(discreteObser) |> ObservationSpace
    observationsAsIndeces = translateObservationsToIndex(discreteObser, observationSpace)

    return(observationSpace, observationsAsIndeces)
end

end
