classdef RdtPathTests < matlab.unittest.TestCase
    
    properties
        withoutTrailing = { ...
            '', ...
            '/foo', ...
            '/foo/bar', ...
            '/foo/bar/baz'};
        withoutLeading = { ...
            '', ...
            'foo/', ...
            'foo/bar/', ...
            'foo/bar/baz/'};
        withBoth = { ...
            '/', ...
            '/foo/', ...
            '/foo/bar/', ...
            '/foo/bar/baz/'};
        withNeither = { ...
            '', ...
            'foo', ...
            'foo/bar', ...
            'foo/bar/baz'};
    end
    
    methods (Test)
        
        function testRoundTripUnchanged(testCase)
            allPaths = cat(2, ...
                testCase.withoutTrailing, ...
                testCase.withoutLeading, ...
                testCase.withBoth, ...
                testCase.withNeither);
            
            testCase.roundTrip(allPaths, allPaths, {'separator', '/'});
        end
        
        function testSubstituteDots(testCase)
            withSlashes = cat(2, ...
                testCase.withoutTrailing, ...
                testCase.withoutLeading, ...
                testCase.withBoth, ...
                testCase.withNeither);
            
            nOriginals = numel(withSlashes);
            withDots = cell(1, nOriginals);
            for ii = 1:nOriginals
                original = withSlashes{ii};
                expected = original;
                expected('/' == expected) = '.';
                withDots{ii} = expected;
            end
            
            testCase.roundTrip(withSlashes, withDots, {'separator', '.'});
        end
        
        function testTrimLeading(testCase)
            fullPathArgs = {'separator', '/', 'trimLeading', true};
            testCase.roundTrip(testCase.withoutTrailing, testCase.withNeither, fullPathArgs);
            testCase.roundTrip(testCase.withoutLeading, testCase.withoutLeading, fullPathArgs);
            testCase.roundTrip(testCase.withBoth, testCase.withoutLeading, fullPathArgs);
            testCase.roundTrip(testCase.withNeither, testCase.withNeither, fullPathArgs);
        end
        
        function testTrimTrailing(testCase)
            fullPathArgs = {'separator', '/', 'trimTrailing', true};
            testCase.roundTrip(testCase.withoutTrailing, testCase.withoutTrailing, fullPathArgs);
            testCase.roundTrip(testCase.withoutLeading, testCase.withNeither, fullPathArgs);
            testCase.roundTrip(testCase.withBoth, testCase.withoutTrailing, fullPathArgs);
            testCase.roundTrip(testCase.withNeither, testCase.withNeither, fullPathArgs);
        end
        
        function testTrimBoth(testCase)
            fullPathArgs = {'separator', '/', 'trimTrailing', true, 'trimLeading', true};
            testCase.roundTrip(testCase.withoutTrailing, testCase.withNeither, fullPathArgs);
            testCase.roundTrip(testCase.withoutLeading, testCase.withNeither, fullPathArgs);
            testCase.roundTrip(testCase.withBoth, testCase.withNeither, fullPathArgs);
            testCase.roundTrip(testCase.withNeither, testCase.withNeither, fullPathArgs);
        end
    end
    
    methods
        function roundTrip(testCase, originals, expecteds, fullPathArgs)
            for ii = 1:numel(originals)
                original = originals{ii};
                expected = expecteds{ii};
                
                pathParts = rdtPathParts(original, 'separator', '/');
                remade = rdtFullPath(pathParts, fullPathArgs{:});
                
                testCase.assertEqual(remade, expected);
            end
        end
        
    end
end
