using HDF5, XLSX, DataFrames

path2018 = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/Germany_2018_bis_2020/2018_data_15min.hdf5"
path2019 = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/Germany_2018_bis_2020/2019_data_15min.hdf5"
path2020 = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/Germany_2018_bis_2020/2020_data_15min.hdf5"

paths = [path2018; path2019; path2020]
households = map(string, [3, 4, 9, 12, 14, 18, 19, 22, 27, 28, 29, 29, 30, 32, 34])
N = length(households)
T = 105216

# Read form HDF5 dataset
data = zeros(Float64, (T, N))
for i in 1:N
    household = households[i]
    vector = []
    for path in paths 
        fid = h5open(path, "r")
        filename = "NO_PV/SFH"*household*"/HOUSEHOLD/table"
        obj = fid[filename]
        A = read(obj)

        dataSingleHousehold = getproperty.(A, :P_TOT)
        vector = [vector; dataSingleHousehold]
        close(fid)
    end
    data[:, i] = vector
end


# Store as .xsxl file
# Nachbearbeitung der Spaltennummerierung in Excel notwendig
path = "C:/Users/Flo/Documents/UNI/Master Thesis/data/load/15households_2years.xlsx"

XLSX.openxlsx(path, mode="w") do file
    sheet = file[1]  # Add a new sheet
    area = "A2:O"*string(T - 14335+1)
    sheet[area] = data[14336:end, :]  # Write matrix elements to the sheet
end


# Read dataframe 
df = DataFrame(XLSX.readtable(path, "Sheet1"))
i = 2
df[:, string(i)]





