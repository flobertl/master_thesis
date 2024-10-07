module Data

using XLSX

function loadObservations(path::String)
    # Öffnen einer Excel-Datei
    xf = XLSX.readxlsx(path)
    sh = xf["UserCustom"] 
    data = sh["B3:B100"]
        
    return(data)
end

function discretize(observations)
    discreteObs = map(round, observations)
    return map(Int, discreteObs)
end

function set(observations)
    return Set(observations)
end
end
