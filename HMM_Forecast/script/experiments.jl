using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise
using Flux, Statistics, HMM_Forecast
using Random

# --------------------
# Hyperparameter
# --------------------
const FEAT   = 5               # Anzahl Eingangsfeatures pro Zeitschritt
const L      = 96            # Lookback: 7 Tage
const H      = 1              # Horizon: 1 Tag
const ALPHAS = collect(0.01:0.07:0.99)  # 9 Quantile
const K      = length(ALPHAS)
const HIDDEN = 64

# --------------------
# Pinball-Loss
# --------------------
@inline function pinball(y, q, α)
    e = y - q
    return e ≥ 0 ? α*e : (α-1)*(e)
end
function monotone_penalty(q::AbstractVector)
    s = 0.0
    @inbounds for i in 1:length(q)-1
        d = q[i] - q[i+1]
        if d > 0
            s += d
        end
    end
    return s
end

# --------------------
# Model: LSTM -> Dense to K*H outputs
# --------------------
myModel = Chain(
    LSTM(FEAT=> HIDDEN),          # 1) LSTM über die Zeitachse
    x -> x[:, end, :],           # 2) letzten Zeitschritt nehmen: (hidden, batch)
    Dense(HIDDEN => 128, relu),    # 1st hidden layer
    Dense(128 => 64, relu),        # 2nd hidden layer
    Dense(64 => K*H),                   # 3) K*H Outputs
    x -> begin                   # 4) in (K, H, batch) reshapen
        B = size(x, 2)
        reshape(x, K, H, B)
    end
)

# --------------------
# Loss for a batch
# ytrue: (H, batch)  ;  ypred: (K, H, batch)
# --------------------
function loss_batch(model, x, ytrue; λ=1f-3)
    Flux.reset!(model)            # LSTM-States pro Batch resetten
    ŷ = model(x)                 # (K, H, B)
    K, H_, B = size(ŷ)
    @assert H_ == H

    s   = 0.0f0
    pen = 0.0f0

    @inbounds for b in 1:B, h in 1:H, k in 1:K
        s += pinball(ytrue[h, b], ŷ[k, h, b], ALPHAS[k])
    end

    @inbounds for b in 1:B, h in 1:H
        pen += monotone_penalty(view(ŷ, :, h, b))
    end

    return s/(B*H*K)  + λ*pen/(B*H)
end

# --------------------
# Dummy dataloader (ersetzte durch echten)
# x: (FEAT, L, BATCH), y: (H, BATCH)
# -------------------


originalObservations = HMM_Forecast.readAndNormalizeData(1)
trainDataIndeces = HMM_Forecast.trainDataIndeces() 

function createBatches(size)
    permutatedIndeces = shuffle(trainDataIndeces)

    batches = []
    for i in 1:size:length(permutatedIndeces)-size
        batchIndeces = permutatedIndeces[i:i+size-1]
        x = zeros(Float32, 5, L, size)
        y = zeros(Float32, H, size)
        for (j,idx) in enumerate(batchIndeces)
            x[:, :, j] = HMM_Forecast.createInputFeatures(originalObservations, idx, L)
            y[:, j]   = originalObservations[idx:idx+H-1]
        end
        push!(batches, (x, y))
        #println(batches)
    end
    return batches
end

function createValidationData(L)
    originalObservations = HMM_Forecast.readAndNormalizeData(1)
    indeces = HMM_Forecast.validationDataIndeces()
    x = zeros(Float32, 5, L, length(indeces))
    y = zeros(Float32, 1, length(indeces))
    for (j,idx) in enumerate(indeces)
        x[:, :, j] = HMM_Forecast.createInputFeatures(originalObservations, idx, L)
        y[:, j]   = originalObservations[idx:idx+H-1]
    end
    return (x, y)
end



opt_state = Flux.setup(Adam(1e-3), myModel)


# --------------------
# Training loop (schematisch)
# --------------------
x_val, y_val = createValidationData(L)
validation_loss_old, validation_loss_new = 1., 1.
for epoch in 1:1
   # prev = now()
    batches = createBatches(1024)
    for (x, y) in batches
        # Expliziter Gradient über das Modell
        grads = Flux.gradient(myModel) do m
            loss_batch(m, x, y; λ=1f-3)
        end

        # Update mit Optimizer-State + Modell + Gradienten
        Flux.update!(opt_state, myModel, grads[1])

        current_loss = loss_batch(myModel, x, y; λ=1f-3)

        @show epoch, current_loss
    #    prevTime = printTimeAndResetTimeStamp(prevTime)
    end
    validation_loss_old = validation_loss_new 
    validation_loss_new = loss_batch(myModel, x_val, y_val)
    # if validation_loss_old < validation_loss_new
    #     break
    # end
end