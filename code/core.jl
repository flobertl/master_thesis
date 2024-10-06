module HMMCore
export Probability
export A

struct Probability
    value::Float64

    function Probability(value::Float64)
        # Überprüfe, ob die Matrix quadratisch ist
        if (value < 0.) || (value > 1.)
            error("Probability $value not in [0,1].")
        end
        # Erzeuge das Objekt
        new(value)
    end
end

struct A
    dimension::UInt
    transitionMatrix::Array{Probability, 2}
    
    function A(dim, transMatrix)
        a,b = size(transMatrix)
        if (a != dim) || (b != dim)
            error("Matrix A not of dim $dim")
        end
        # Erzeuge das Objekt
        new(dim, transMatrix)
    end
end

struct B
    dimension::Tuple{Int,Int}
    transitionMatrix::Array{Probability, 2}

    function B((dim1, dim2), transMatrix)
        a,b = size(transMatrix)
        if (a != dim1) || (b != dim2)
            error("Matrix B not of dim $dim1*$dim2")
        end
        # Erzeuge das Objekt
        new((dim1, dim2), transMatrix)
    end
end

struct observation
    observation::Int
end


struct observationSpace
    obersations::Array{observation}
end


struct HMM 
    numberOfStateSpace::Int
    transitionMatrix::A
    observationMatrix::B
    observationSpace::observationSpace
end
end