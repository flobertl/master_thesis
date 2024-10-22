module Data

using Main.HMM.Types
using XLSX

export loadObservations, discretize

function loadObservations(path::String)
    # Öffnen einer Excel-Datei
    xf = XLSX.readxlsx(path)
    sh = xf["UserCustom"] 
    data = sh["B3:B100"] |> vec
        
    return(data)
end

function discretize(observations)
    discreteObs = map(round, observations)
    return map(Int, discreteObs)
end

end
