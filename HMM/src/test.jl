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

function testAll()
    ()
end

end