# Arrays/Vectors
a = [2, 3, 5]
a[2]
a = append!(a, 4)
typeof(a)

# Matrices
mat32 = [1 2 3; 4  5 6]
mat1 = [1 2 3]

# N-Dim Arrays
table = zeros(2,3,4)
for i in 1:2
    for j in 1:3 
        for k in 1:4
            table[i,j,k] = i*j- k
        end
    end
end
table

# Slicing
a = [1, 2, 3, 4, 5, 5]
b = mat32[1,2:3]

mat1 = reshape(1:16,4,4)
[i+j for i in 1:10 for j in 1:5]

# Views
a=[1,2,3]
b=a
b[2] = 42
print(a)

a=[1,2,3]
b=copy(a)
b[2] = 42
a

# Scope
const C = 2344
