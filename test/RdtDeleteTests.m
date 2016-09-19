classdef RdtDeleteTests < matlab.unittest.TestCase
    % Test that we can delete artifacts locally and remotely.
    % These tests attempt to connect to our public Archiva server called
    % brainard-archiva, using expected test credentials and repository
    % contents. If the expected server can't be found, skips these tests.
    
    properties (Access = private)
        testConfig = rdtConfiguration( ...
            'serverUrl', 'http://52.32.77.154', ...
            'repositoryUrl', 'http://52.32.77.154/repository/test-repository', ...
            'repositoryName', 'test-repository', ...
            'username', 'test', ...
            'password', 'speHewe8eba3', ...
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
        function testDeletePathLocally(testCase)
            published = testCase.publishTestArtifact();
            
            % should find local path for published artifact
            [localPath, fullPath] = rdtListLocalPaths(testCase.testConfig, ...
                'remotePath', published.remotePath);
            testCase.assertNotEmpty(localPath);
            testCase.assertNotEmpty(fullPath);
            testCase.assertEqual(localPath{1}, published.remotePath);
            testCase.assertEqual(exist(fullPath{1}, 'dir'), 7);
            
            [deleted, notDeleted] = rdtDeleteLocalPaths(testCase.testConfig, published.remotePath);
            testCase.assertNotEmpty(deleted);
            testCase.assertEqual(deleted{1}, published.remotePath);
            testCase.assertEmpty(notDeleted);
            
            % should no longer find local path
            [localPath, fullPath] = rdtListLocalPaths(testCase.testConfig, ...
                'remotePath', published.remotePath);
            testCase.assertEmpty(localPath);
            testCase.assertEmpty(fullPath);
        end
        
        function testDeletePathRemotely(testCase)
            published = testCase.publishTestArtifact();
            
            % should find local path for published artifact
            [localPath, fullPath] = rdtListLocalPaths(testCase.testConfig, ...
                'remotePath', published.remotePath);
            testCase.assertNotEmpty(localPath);
            testCase.assertNotEmpty(fullPath);
            testCase.assertEqual(localPath{1}, published.remotePath);
            testCase.assertEqual(exist(fullPath{1}, 'dir'), 7);
            
            [deleted, notDeleted] = rdtDeleteRemotePaths(testCase.testConfig, published.remotePath);
            testCase.assertNotEmpty(deleted);
            testCase.assertEqual(deleted{1}, published.remotePath);
            testCase.assertEmpty(notDeleted);
            
            % should no longer find local path
            [localPath, fullPath] = rdtListLocalPaths(testCase.testConfig, ...
                'remotePath', published.remotePath);
            testCase.assertEmpty(localPath);
            testCase.assertEmpty(fullPath);
            
            % should no longer be able to read remote artifact
            try
                [data, artifact] = rdtReadArtifacts(testCase.testConfig, published);
            catch
                data = {};
                artifact = {};
            end
            testCase.assertEmpty(data);
            testCase.assertEmpty(artifact);
        end
        
        function testDeleteAsListedLocally(testCase)
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
        
        function testDeleteAsPublishedLocally(testCase)
            published = testCase.publishTestArtifact();
            [deleted, notDeleted] = rdtDeleteLocalArtifacts(testCase.testConfig, ...
                published);
            
            testCase.assertNotEmpty(deleted);
            testCase.assertInstanceOf(deleted, 'struct');
            testCase.assertTrue(all(strcmp(published.artifactId, {deleted.artifactId})));
            
            testCase.assertEmpty(notDeleted);
        end
        
        function testBogusNotDeletedLocally(testCase)
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
        
        function testSomeRealSomeBogusLocally(testCase)
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
        
        % TODO: would be nice to have another remote test,
        % testDeleteAsListedRemotely().  This would publish, then query for
        % a listing that includes the just-published artifact, then delete
        % using that listing.  Deleting based on a listing is probably how
        % users will use the API.
        %
        % But this test must wait because getting an up-to-date listing
        % would require us to trigger a repository re-scan immediately
        % following the publishing.  We havne't implemented
        % client-triggered re-scanning yet.
        
        function testDeleteAsPublishedRemotely(testCase)
            published = testCase.publishTestArtifact();
            [deleted, notDeleted] = rdtDeleteArtifacts(testCase.testConfig, ...
                published);
            
            testCase.assertNotEmpty(deleted);
            testCase.assertInstanceOf(deleted, 'struct');
            testCase.assertTrue(all(strcmp(published.artifactId, {deleted.artifactId})));
            
            testCase.assertEmpty(notDeleted);
        end
        
        function testBogusNotDeletedRemotely(testCase)
            bogus = rdtArtifact( ...
                'artifactId', 'bogus-artifact', ...
                'localPath', 'nonononotapath', ...
                'remotePath', 'ringadongdillo');
            [deleted, notDeleted] = rdtDeleteArtifacts(testCase.testConfig, ...
                bogus);
            
            testCase.assertEmpty(deleted);
            
            testCase.assertNotEmpty(notDeleted);
            testCase.assertInstanceOf(notDeleted, 'struct');
            testCase.assertEqual(notDeleted.artifactId, bogus.artifactId);
        end
        
        function testSomeRealSomeBogusRemotely(testCase)
            published = testCase.publishTestArtifact();
            
            boguses(1) = rdtArtifact( ...
                'artifactId', 'bogus-artifact-1', ...
                'localPath', 'nonononotapath', ...
                'remotePath', published.remotePath);
            boguses(2) = rdtArtifact( ...
                'artifactId', 'bogus-artifact-2', ...
                'localPath', 'heydolmerrydol', ...
                'remotePath', published.remotePath);
            [deleted, notDeleted] = rdtDeleteArtifacts(testCase.testConfig, ...
                [published, boguses]);
            
            % Archiva actually reports successful deletion for bogus
            % artifacts.  I guess its interpretation of success is that
            % the artifact does not exist on the server, which is true of
            % deleted artifacts as well as artifacts that never existed.
            % So just check that the previously published artifact is among
            % those that don't exist.
            testCase.assertNotEmpty(deleted);
            testCase.assertInstanceOf(deleted, 'struct');
            testCase.assertTrue(any(strcmp({deleted.artifactId}, published.artifactId)));
        end
    end
    
    methods
        % Publish a throw-away artifact that's independent of other tests.
        function [artifact, testArtifactData] = publishTestArtifact(testCase)
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