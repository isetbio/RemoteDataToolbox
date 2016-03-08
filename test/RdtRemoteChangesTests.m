classdef RdtRemoteChangesTests < matlab.unittest.TestCase
    % Test that we can make artifact changes made remotely.
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
    end
    
    methods (TestMethodSetup)
        
        function checkIfServerPresent(testCase)
            [isConnected, message] = rdtPingServer(testCase.testConfig);
            testCase.assumeTrue(isConnected, message);
        end
        
    end
    
    methods (Test)
        
        function testDetectRemoteUpdate(testCase)
            % use two separate cache folders, "a" and "b",
            %   a to simulate clients on separate machines
            
            % always start with fresh local caches
            testDir = fullfile(tempdir(), 'RdtRemoteChangesTest');
            if exist(testDir, 'dir')
                rmdir(testDir, 's');
            end
            mkdir(testDir);
            
            configA = testCase.testConfig;
            configA.cacheFolder = fullfile(testDir, 'cache-a');
            
            configB = testCase.testConfig;
            configB.cacheFolder = fullfile(testDir, 'cache-b');
            
            % publish a test file from client A
            testFile = fullfile(testDir, 'testFile.mat');
            testData = 42;
            save(testFile, 'testData');
            published = rdtPublishArtifact(configA, testFile, 'test-path', ...
                'version', '0');
            
            % verify we can read the original file from both clients
            dataA = rdtReadArtifacts(configA, published);
            testCase.assertNotEmpty(dataA);
            testCase.assertInstanceOf(dataA{1}, 'struct');
            testCase.assertEqual(dataA{1}.testData, testData);
            
            dataB = rdtReadArtifacts(configB, published);
            testCase.assertNotEmpty(dataB);
            testCase.assertInstanceOf(dataB{1}, 'struct');
            testCase.assertEqual(dataB{1}.testData, testData);
            
            % now A and B each has a cached copy of the original artifact
            
            % update the artifact from client B
            updateData = 'This is not the answer!';
            save(testFile, 'updateData');
            updated = rdtPublishArtifact(configB, testFile, 'test-path', ...
                'version', '0');
            
            % verify we can see the update from both clients
            updatedB = rdtReadArtifacts(configB, updated);
            testCase.assertNotEmpty(updatedB);
            testCase.assertInstanceOf(updatedB{1}, 'struct');
            testCase.assertEqual(updatedB{1}.updateData, updateData);
            
            % the tricky part: does clientA detect the remote update?
            updatedA = rdtReadArtifacts(configA, updated);
            testCase.assertNotEmpty(updatedA);
            testCase.assertInstanceOf(updatedA{1}, 'struct');
            testCase.assertEqual(updatedA{1}.updateData, updateData);
            
        end
    end
end
