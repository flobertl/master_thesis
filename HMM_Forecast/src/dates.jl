using Dates

# --------------------------------------------------------
# Dates and Indices for 2 Year data

startOfJune18 = 158

function dateTimesOf2YearsData()
    return(DateTime(2018,05,30, 08, 45):Minute(15):DateTime(2021,01,01,00,45))
end

function calcFirstQHofYearAndMonth()::Array{Int, 2}  # Made possible by ChatGPT
    # Define year range and months
    years = 2018:2020
    months = 1:12

    # Create a dictionary to map year → index in the array
    year_idx = Dict(y => i for (i, y) in enumerate(years))

    # Initialize 3D array with NaN values
    result = zeros(Int, 3, 12)  # The third dim will grow dynamically
    current_index = 158  # Given index for June 2018

    for y in years
        for m in months
            # Compute number of quarter-hours in this month
            first_day = Date(y, m, 1)
            num_quarter_hours = Dates.daysinmonth(first_day) * 24 * 4 |> Int # days * hours * 4 (quarter-hours)

            # Get year and month index for the array
            yi = year_idx[y]  # Map year to array index

            if y == 2018 && m < 6
                # Keep NaN for months before June 2018
                result[yi, m] = 0
            else
                # Store the current index
                result[yi, m] = current_index |> Int
                # Move to next index
                current_index += num_quarter_hours
            end
        end
    end
    return result
end

dateIndeces = calcFirstQHofYearAndMonth()


function endOfDecember20()
     (dateTimesOf2YearsData() |> length) -4
end

function trainDataIndeces()
    return dateIndeces[2,1]:dateIndeces[3,1]-1 |> Vector      
end

# train Data for TESTING Purpose (only 2 days of data)
function trainDataIndecesTEST()
    return dateIndeces[2,1]:dateIndeces[2,1]+500 |> Vector      
end


# Indeces Test Data Set
# Every 2nd month (Feb, April, June,...) of the 3rd Year
function testDataIndeces()::Vector{Int64}
    testDataIndeces = []
    for month in 2:2:10
        indeces = dateIndeces[3, month] : dateIndeces[3, month+1]-1
        append!(testDataIndeces, indeces)
    end
    december20Indeces = dateIndeces[3, 12]: endOfDecember20()
    append!(testDataIndeces, december20Indeces)
    return testDataIndeces
end


# Indeces validation Data Set
# Every 2nd Month (Jan, March, May,..) of the 3rd Year
function validationDataIndeces()::Vector{Int64}
    validationDataIndeces = []
    for month in 1:2:11
        indeces = dateIndeces[3, month] : dateIndeces[3, month+1]-1
        append!(validationDataIndeces, indeces)
    end
    return validationDataIndeces
end

# Specific Season dates
startJuni18 = 4*(24+15)+2 
startSeptember18 = startJuni18 + 24*4*92
startDezember18 = startSeptember18 + 24*4*91
startMärz19 = startDezember18 + 24*4*90
startJuni19 = startMärz19 + 24*4*92
startSeptember19 = startJuni19 + 24*4*92
startDezember19 = startSeptember19 + 24*4*91
startMärz20 = startDezember19 + 24*4*91
startJuni20 = startMärz20 + 24*4*92
startSeptember20 = startJuni20 + 24*4*92
startDezember20 = startSeptember20 + 24*4*91

seasonsByYear = Dict(
    "Sommer18" => (startJuni18,startSeptember18-1),
    "Sommer19" => (startJuni19,startSeptember19-1),
    "Sommer20" => (startJuni20,startSeptember20-1),
    "Herbst18" => (startSeptember18,startDezember18-1),
    "Herbst19" => (startSeptember19,startDezember19-1),
    "Herbst20" => (startSeptember20,startDezember20-1),
    "Frühling19" => (startMärz19,startJuni19-1),
    "Frühling20" => (startMärz20,startJuni20-1),
    "Winter18" => (startDezember18,startMärz19-1),
    "Winter19" => (startDezember19,startMärz20-1)
    )

seasons = Dict(
    "Summer"    => ((startJuni19,startSeptember19-1)),
    "Autumn"    => ((startSeptember19,startDezember19-1)),
    "Spring"  => ((startMärz19,startJuni19-1)),
    "Winter"    => ((startDezember19,startMärz20-1))
    )

#############################################################################
## Legacy

# Season Data
trainDataFallIndeces = dateIndeces[2, 9] : (dateIndeces[2, 12] - 1)
testDataFallIndeces = dateIndeces[3, 9] : (dateIndeces[3, 12] - 1)
trainDataWinterIndeces = dateIndeces[1, 12] : (dateIndeces[2, 3] - 1)
testDataWinterIndeces = dateIndeces[2, 12] : (dateIndeces[3, 3] - 1)
trainDataSpringIndeces = dateIndeces[2, 3] : (dateIndeces[2, 6] - 1)
testDataSpringIndeces = dateIndeces[3, 3] : (dateIndeces[3, 6] - 1)
trainDataSummerIndeces = dateIndeces[2, 6] : (dateIndeces[2, 9] - 1)
testDataSummerIndeces = dateIndeces[3, 6] : (dateIndeces[3, 9] - 1)

seasonStrings = ["spring", "summer", "fall", "winter"]

# Indeces first 2 Weeks of Seasons 
testData2WeeksForAllSeasons = vcat(testDataSpringIndeces[1:96*7*2], testDataSummerIndeces[1:96*7*2], testDataFallIndeces[1:96*7*2], testDataWinterIndeces) 
