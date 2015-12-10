classdef RdtJsonTests < matlab.unittest.TestCase
    
    methods (Test)
        
        function testStructRoundTrip(testCase)
            s.integer = 1;
            s.double = pi();
            s.string = 'asdf';
            s.struct = s;
            s.cell = fieldnames(s)';
            s.matrix = rand(10, 10, 10);
            s.logical = [true, false];
            s.nonFinites = [-inf, inf, nan];
            
            jsonString = rdtToJson(s);
            sPrime = rdtFromJson(jsonString);
            
            testCase.assertEqual(s, sPrime, 'AbsTol', 1e-15);
        end
    end
end
