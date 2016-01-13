classdef RdtDeleteTests < matlab.unittest.TestCase
    % Test that we can find and delete locally cached artifacts.
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
        function testDeleteAsListed(testCase)
            published = testCase.publishTestArtifact();
            foundLocally = rdtListLocalArtifacts(testCase.testConfig, ...
                published.remotePath, ...
                'artifactId', published.artifactId);
            
            testCase.assertNotEmpty(foundLocally);
            testCase.assertInstanceOf(foundLocally, 'struct');
            testCase.assertTrue(all(strcmp(published.artifactId, {foundLocally.artifactId})));
            
            [deleted, notDeleted] = rdtDeleteLocalArtifacts(testCase.testConfig, ...
                foundLocally);
            
            testCase.assertNotEmpty(deleted);
            testCase.assertInstanceOf(deleted, 'struct');
            testCase.assertEqual(sort({deleted.artifactId}), sort({foundLocally.artifactId}));
            
            testCase.assertEmpty(notDeleted);
        end
        
        function testDeleteAsPublished(testCase)
            published = testCase.publishTestArtifact();
            [deleted, notDeleted] = rdtDeleteLocalArtifacts(testCase.testConfig, ...
                published);
            
            testCase.assertNotEmpty(deleted);
            testCase.assertInstanceOf(deleted, 'struct');
            testCase.assertTrue(all(strcmp(published.artifactId, {deleted.artifactId})));
            
            testCase.assertEmpty(notDeleted);
        end
        
        function testBogusNotDeleted(testCase)
            bogus = rdtArtifact( ...
                'artifactId', 'bogus-artifact', ...
                'localPath', 'nonononotapath');
            [deleted, notDeleted] = rdtDeleteLocalArtifacts(testCase.testConfig, ...
                bogus);
            
            testCase.assertEmpty(deleted);
            
            testCase.assertNotEmpty(notDeleted);
            testCase.assertInstanceOf(notDeleted, 'struct');
            testCase.assertEqual(notDeleted.artifactId, bogus.artifactId);
        end
        
        function testSomeRealSomeBogus(testCase)
            published = testCase.publishTestArtifact();
            foundLocally = rdtListLocalArtifacts(testCase.testConfig, ...
                published.remotePath, ...
                'artifactId', published.artifactId);
            
            boguses(1) = rdtArtifact( ...
                'artifactId', 'bogus-artifact-1', ...
                'localPath', 'nonononotapath');
            boguses(2) = rdtArtifact( ...
                'artifactId', 'bogus-artifact-2', ...
                'localPath', 'thisisiaboguspath');
            [deleted, notDeleted] = rdtDeleteLocalArtifacts(testCase.testConfig, ...
                [foundLocally, boguses]);
            
            testCase.assertNotEmpty(deleted);
            testCase.assertInstanceOf(deleted, 'struct');
            testCase.assertEqual(sort({deleted.artifactId}), sort({foundLocally.artifactId}));
            
            testCase.assertNotEmpty(notDeleted);
            testCase.assertInstanceOf(notDeleted, 'struct');
            testCase.assertEqual(sort({notDeleted.artifactId}), sort({boguses.artifactId}));
        end
        
    end
    
    methods
        function [artifact, testArtifactData] = publishTestArtifact(testCase)
            % Actually publishing something seems like the best way to get
            % something in the local cache that we are free to delete.
            % This avoids interaction with other tests and also avoids
            % unintended side effects of finding some other way to populate
            % the cache.
            
            testArtifactData = 'please delete me!';
            save(testCase.testArtifactFile, 'testArtifactData');
            
            artifact = rdtPublishArtifact(testCase.testConfig, ...
                testCase.testArtifactFile, ...
                'delete-me', ...
                'artifactId', 'delete-me', ...
                'version', '0', ...
                'name', 'Dr. Delete', ...
                'description', 'Please delete this temporary test artifact.');
        end
    end
end