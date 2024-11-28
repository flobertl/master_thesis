module Data

using Main.HMM.Types
using XLSX

export loadObservations2, loadObservations1 , discretize

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

end
