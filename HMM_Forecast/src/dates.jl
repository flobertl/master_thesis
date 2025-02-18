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

function endOfDecember20()
     (dateTimesOf2YearsData() |> length) -4
end

# Season Data
dateIndeces = calcFirstQHofYearAndMonth()
trainDataFallIndeces = dateIndeces[2, 9] : (dateIndeces[2, 12] - 1)
testDataFallIndeces = dateIndeces[3, 9] : (dateIndeces[3, 12] - 1)
trainDataWinterIndeces = dateIndeces[1, 12] : (dateIndeces[2, 3] - 1)
testDataWinterIndeces = dateIndeces[2, 12] : (dateIndeces[3, 3] - 1)
trainDataSpringIndeces = dateIndeces[2, 3] : (dateIndeces[2, 6] - 1)
testDataSpringIndeces = dateIndeces[3, 3] : (dateIndeces[3, 6] - 1)
trainDataSummerIndeces = dateIndeces[2, 6] : (dateIndeces[2, 9] - 1)
testDataSummerIndeces = dateIndeces[3, 6] : (dateIndeces[3, 9] - 1)

seasonStrings = ["spring", "summer", "fall", "winter"]
