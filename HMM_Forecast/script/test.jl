using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, ChangePrecision
using HMM_Forecast

@changeprecision Float32 begin

#runUEAll()
    HMM_Forecast.testAll()

end

HMM_Forecast.testObservationToIndexMapping()
