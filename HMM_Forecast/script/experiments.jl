using(Pkg)
Pkg.activate("HMM_Forecast")
using Revise, ChangePrecision, Plots
using HMM_Forecast
using Plots
# Create some sample data
l = @layout [
    a{0.3w} [grid(3,3)
             b{0.2h}  ]
]
plot(
    rand(10, 11);
    layout = l, legend = false, seriestype = [:bar :scatter :path],
    title = ["($i)" for j in 1:1, i in 1:11], titleloc = :right, titlefont = font(8)
)