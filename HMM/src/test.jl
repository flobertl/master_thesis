module Test

using Main.HMM.Types, Main.HMM.Helpers, Main.HMM.Calc

export testAll

epsilon = 1E-10

function testingEquality(testName::String, testingValue, expectedResult)
    if (expecteResult < testingValue - epsilon) & (expecteResult > testingValue + epsilon)
        println("Test" + testName+" failed!")
    else
        println("Test" + testName+" succeded")
    end
end

module ForwardAlgo
    function testForwardCalc()
        name = "Helper forwardCalc"

        alpha_tminus1 = ones(4)
        a_point_i = ones(4)
        b_point_o_t = ones(4)
        value = forwardCalc(alpha_tminus1, a_point_i, b_point_o_t)

        testingEquality(value, 4)
    end
end

function testAll()
    ()
end

end