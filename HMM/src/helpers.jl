module Helpers

using Main.HMM.Types

export translateObservationsToIndex, translateIndexToObservations, forwardCalc, backwardCalc

function translateObservationsToIndex(observations::Vector{Int}, observationSpace::ObservationSpace)
    T = length(observations)
    observationsAsIndex = zeros(Int, T)
    for t in 1:T
        observationsAsIndex[t] = observationSpace.mapObservationToIndex[observations[t]]
    end
    return observationsAsIndex
end

function translateIndexToObservations(observationsAsIndex::Array{Int, 1}, observationSpace::ObservationSpace)
    T = length(observationsAsIndex)
    observations = zeros(T)
    for t in 1:T
        observations[t] = observationSpace.mapIndexToObservation[observationsAsIndex[t]]
    end
    return observations
end

function forwardCalc(alpha_tminus1::Array{Float64, 1}, a_point_i::Array{Float64, 1}, b_point_o_t::Array{Float64, 1})
    alpha_tminus1 .* a_point_i .* b_point_o_t
end

function backwardCalc(beta_tplus1::Array{Float64, 1}, a_i_point::Array{Float64, 1}, b_point_o_tplus1::Array{Float64, 1})
    beta_tplus1 .* a_i_point .* b_point_o_tplus1
end

end