using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, ChangePrecision, Plots
using HMM_Forecast
using ScikitLearn, Random, Distributions

Random.seed!(123)

N = 10000                          # number of samples
x = 10 .* rand(N) 
push!(x, NaN)             # uniform random values in [0, 10]
epsi = rand(Normal(0, 1), N+1)        # normal error, mean 0, variance 1
y = x .+  epsi

# Feature matrix must be (n_samples, n_features)
X = reshape(x, :, 1)

# Import QuantileRegressor from scikit-learn
@sk_import linear_model: QuantileRegressor

# Fit the 95% quantile (q = 0.95)
for quant in 0.05:0.1:0.95
        qr = QuantileRegressor(quantile=quant, alpha=0.0, solver="highs")   # you can also set e.g. alpha=0.0, solver="highs"
        fit!(qr, X, y)

        # Predictions (on training X here, but you can use new X as well)
        ŷ = predict(qr, X)

        # Inspect fitted line (intercept + slope)
        intercept = qr.intercept_
        coefs     = qr.coef_
        println("$quant quantile fit: y ≈ $(round(intercept, digits=4)) + $(coefs) * x")
end

# Plots
using Plots 

# sort for a clean line plot
perm = sortperm(x)
xs   = x[perm]
ŷs   = ŷ[perm]

scatter(x, y, alpha=0.5, label="data", xlabel="x", ylabel="y",
        title="Quantile Regression (q = 0.95)", legend=:topleft)
plot!(xs, ŷs, linewidth=3, label="95% quantile fit")
