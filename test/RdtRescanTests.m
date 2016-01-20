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
            config.password = 'nononononeithersayfriendnorenter';
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
        
        function testModifyRepository(testCase)
            % create a random test artifact
            testArtifactData = rand(42, 43);
            save(testCase.testArtifactFile, 'testArtifactData');
            
            % create a random artifact id to isolate this test
            alphabet = 'a':'z';
            artifactId = alphabet(randperm(numel(alphabet)));
            remotePath = 'rescan-group';
            
            % publish the artifact
            published = rdtPublishArtifact(testCase.testConfig, ...
                testCase.testArtifactFile, ...
                remotePath, ...
                'artifactId', artifactId);
            testCase.assertNotEmpty(published);
            testCase.assertInstanceOf(published, 'struct');
            testCase.assertEqual(published.artifactId, artifactId);
            
            % publish should have triggered a repository re-scan
            %   so we should be able to list and search immediately
            listed = rdtListArtifacts(testCase.testConfig, ...
                remotePath, ...
                'artifactId', artifactId);
            testCase.assertNotEmpty(listed);
            testCase.assertInstanceOf(listed, 'struct');
            testCase.assertEqual(listed.artifactId, artifactId);
            
            found = rdtSearchArtifacts(testCase.testConfig, ...
                artifactId, ...
                'artifactId', artifactId, ...
                'remotePath', remotePath);
            testCase.assertNotEmpty(found);
            testCase.assertInstanceOf(found, 'struct');
            testCase.assertEqual(found.artifactId, artifactId);
            
            listedPaths = rdtListRemotePaths(testCase.testConfig);
            testCase.assertNotEmpty(listedPaths);
            testCase.assertTrue(any(strcmp(listedPaths, remotePath)));
            
            % delete the artifact
            deleted = rdtDeleteArtifacts(testCase.testConfig, ...
                published);
            testCase.assertNotEmpty(deleted);
            testCase.assertInstanceOf(deleted, 'struct');
            testCase.assertEqual(deleted.artifactId, artifactId);
            
            % delete should have triggered a repository re-scan
            %   so we should no longer be able to list and search
            listedAgain = rdtListArtifacts(testCase.testConfig, ...
                remotePath, ...
                'artifactId', artifactId);
            testCase.assertEmpty(listedAgain);
            
            foundAgain = rdtSearchArtifacts(testCase.testConfig, ...
                artifactId, ...
                'artifactId', artifactId, ...
                'remotePath', remotePath);
            testCase.assertEmpty(foundAgain);
            
            % delete the remote group
            deleted = rdtDeleteRemotePaths(testCase.testConfig, remotePath);
            testCase.assertNotEmpty(deleted);
            testCase.assertTrue(any(strcmp(deleted, remotePath)));
            
            % delete should have triggered a repository re-scan
            %   so we should no longer be able to list the path
            listedPaths = rdtListRemotePaths(testCase.testConfig);
            testCase.assertNotEmpty(listedPaths);
            testCase.assertFalse(any(strcmp(listedPaths, remotePath)));
        end
    end
end
