using HDF5

path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/Germany_2018_bis_2020/2019_data_15min.hdf5"

fid = h5open(path, "r")

obj = fid["NO_PV/SFH3/HOUSEHOLD/table"]
A = read(obj)

olumn = getproperty.(A, :P_TOT)