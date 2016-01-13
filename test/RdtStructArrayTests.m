classdef RdtStructArrayTests < matlab.unittest.TestCase
    
    properties (Constant)
        structArray = struct( ...
            'strings', {'zebra', 'yak', 'xylophish', 'albinoni', 'walmart', 'chess', 'frescobaldi'}, ...
            'stringsEmpty', {'zebra', '', 'xylophish', 'albinoni', char(0, 1), '', char(1, 0)}, ...
            'numeric', {1e6, 5, 4*pi(), -exp(3), 0, 0, 100}, ...
            'numericEmpty', {1e6, [], 4*pi(), -exp(3), [], 0, 100});
    end
    
    methods (Test)
        
        function tesstSortEmpty(testCase)
            [sorted, order] = rdtSortStructArray(struct('a', {}), 'a');
            testCase.assertEmpty(sorted);
            testCase.assertEmpty(order);
        end
        
        function tesstSortNotAfield(testCase)
            [sorted, order] = rdtSortStructArray(testCase.structArray, 'nonononotafield');
            testCase.assertEqual(sorted, testCase.structArray, 'AbsTol', 1e-15);
            testCase.assertEqual(order, 1:numel(testCase.structArray));
        end
        
        function testSortStrings(testCase)
            [sorted, order] = rdtSortStructArray(testCase.structArray, 'strings');
            testCase.assertEqual(order, [4 6 7 5 3 2 1]);
            remade = testCase.structArray(order);
            testCase.assertEqual(remade, sorted, 'AbsTol', 1e-15);
        end
        
        function testSortNumerics(testCase)
            [sorted, order] = rdtSortStructArray(testCase.structArray, 'numeric');
            testCase.assertEqual(order, [4 5 6 2 3 7 1]);
            remade = testCase.structArray(order);
            testCase.assertEqual(remade, sorted, 'AbsTol', 1e-15);
        end
        
        function testSortStringsEmptyValues(testCase)
            [sorted, order] = rdtSortStructArray(testCase.structArray, 'stringsEmpty');
            testCase.assertEqual(order, [2 6 5 7 4 3 1]);
            remade = testCase.structArray(order);
            testCase.assertEqual(remade, sorted, 'AbsTol', 1e-15);
        end
        
        function testSortNumericsEmptyValues(testCase)
            [sorted, order] = rdtSortStructArray(testCase.structArray, 'numericEmpty');
            testCase.assertEqual(order, [4 6 3 7 1 2 5]);
            remade = testCase.structArray(order);
            testCase.assertEqual(remade, sorted, 'AbsTol', 1e-15);
        end
    end
end
