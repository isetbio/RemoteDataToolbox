classdef RdtLocalCacheTests < matlab.unittest.TestCase
    % Test that we can list and delete artifacts from the local cache.
    % These tests attempt to connect to our public Archiva server called
    % brainard-archiva, using expected test credentials and repository
    % contents. If the expected server can't be found, skips these tests.
    
    properties (Access = private)
        testConfig = rdtConfiguration( ...
            'serverUrl', 'http://52.32.77.154', ...
            'repositoryUrl', 'http://52.32.77.154/repository/test-repository', ...
            'repositoryName', 'test-repository', ...
            'username', 'test', ...
            'password', 'ZeBacu5R', ...
            'requestMediaType', 'application/json', ...
            'acceptMediaType', 'application/json', ...
            'verbosity', 1);
        listed;
    end
    
    methods (TestMethodSetup)
        
        function checkIfServerPresent(testCase)
            [isConnected, message] = rdtPingServer(testCase.testConfig);
            testCase.assumeTrue(isConnected, message);
            
            % make sure we have some things in the local cache
            testCase.listed = rdtListArtifacts(testCase.testConfig, 'test-group-1');
            rdtReadArtifacts(testCase.testConfig, testCase.listed);
        end
        
    end
    
    methods (Test)
        function testListLocalHitNone(testCase)
            artifacts = rdtListLocalArtifacts(testCase.testConfig, 'nonononotamatch');
            testCase.assertEmpty(artifacts);
        end
        
        function testListLocalhHitMany(testCase)
            artifacts = rdtListLocalArtifacts(testCase.testConfig, 'test-group-1');
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertGreaterThanOrEqual(numel(artifacts), numel(testCase.listed));
        end
        
        function testListLocalRestrictArtifactId(testCase)
            artifacts = rdtListLocalArtifacts(testCase.testConfig, 'test-group-1', ...
                'artifactId', 'text-artifact');
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNotEmpty(artifacts);
            testCase.assertTrue(all(strcmp({artifacts.artifactId}, 'text-artifact')));
        end
        
        function testListLocalRestrictVersion(testCase)
            artifacts = rdtListLocalArtifacts(testCase.testConfig, 'test-group-1', ...
                'version', '1');
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNotEmpty(artifacts);
            testCase.assertTrue(all(strcmp({artifacts.version}, '1')));
        end
        
        function testListLocalRestrictType(testCase)
            artifacts = rdtListLocalArtifacts(testCase.testConfig, 'test-group-1', ...
                'type', 'mat');
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNotEmpty(artifacts);
            testCase.assertTrue(all(strcmp({artifacts.type}, 'mat')));
        end
    end
end
