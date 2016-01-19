classdef RdtRescanTests < matlab.unittest.TestCase
    % Test that we can trigger re-scans of Archiva repositories.
    % These tests attempt to connect to our public Archiva server called
    % brainard-archiva, using expected test credentials and repository
    % contents. If the expected server can't be found, skips these tests.
    
    properties (Access = private)
        testConfig = rdtConfiguration( ...
            'serverUrl', 'http://52.32.77.154', ...
            'repositoryUrl', 'http://52.32.77.154/repository/test-repository', ...
            'repositoryName', 'test-repository', ...
            'username', 'test', ...
            'password', 'test123', ...
            'requestMediaType', 'application/json', ...
            'acceptMediaType', 'application/json', ...
            'verbosity', 1);
        
        testArtifactFile = fullfile(tempdir(), 'temp-artifact.mat');
    end
    
    methods (TestMethodSetup)
        
        function checkIfServerPresent(testCase)
            [isConnected, message] = rdtPingServer(testCase.testConfig);
            testCase.assumeTrue(isConnected, message);
        end
    end
    
    methods (TestMethodTeardown)
        function deleteTestArtifact(testCase)
            if exist(testCase.testArtifactFile, 'file')
                delete(testCase.testArtifactFile);
            end
        end
    end
    
    methods (Test)
        
        function testBadCredentials(testCase)
            config = testCase.testConfig;
            config.username = 'nonononotauser';
            config.password = 'nonononodontsayfriendandenter';
            isStarted = rdtRequestRescan(config);
            testCase.assertFalse(isStarted);
        end
        
        function testGoodCredentials(testCase)
            isStarted = rdtRequestRescan(testCase.testConfig);
            testCase.assertTrue(isStarted);
        end
        
        function testTimeout(testCase)
            isStarted = rdtRequestRescan(testCase.testConfig, ...
                'timeout', 10);
            testCase.assertTrue(isStarted);
        end        
    end
end
