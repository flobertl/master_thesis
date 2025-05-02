# Regular Functions
function powerToTwo(x)
    return x^2
end

# Inline Functions
squarRoot(x) = sqrt(x) 

# Lambda function
identityMinusOne = x -> x -1

using Pkg
Pkg.add("QuadGK")
using QuadGK

f(x,y,z) = (x^2+2y)*z

f(1,1.,1)

# Void function
function say_bulgi()
    println("Bulgiiiii!")
    return 1
end

say_bulgi()

# Optional positional arguments
function myWeight(weightOnEarth, g = 9.81)
    return weightOnEarth*g/9.81
end

myWeight(75, 3.53)

# Keyword arguments
function my_long_function(a, b=2; c, d=3)
    return a + b + c + d
end

my_long_function(1, c=4)
my_long_function(1,2, c=4, d=4)

#Function documentation
"""
gaxilulu
"""
function helloPupsi(x) 
    #... gaxilulu
    return x +1   
end