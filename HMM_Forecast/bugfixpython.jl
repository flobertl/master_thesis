using Pkg
Pkg.rm("PyCall")
Pkg.rm("Conda")

rm(joinpath(DEPOT_PATH[1], "conda"), recursive=true, force=true)
rm(joinpath(DEPOT_PATH[1], "packages", "PyCall"), recursive=true, force=true)

ENV["PYTHON"] = raw"C:/Users/anton/AppData/Local/Microsoft/WindowsApps/python.exe"  # adjust if needed

Pkg.add("PyCall")
Pkg.build("PyCall")

using PyCall
println(PyCall.python)
