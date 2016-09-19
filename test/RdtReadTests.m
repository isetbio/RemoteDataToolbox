classdef RdtReadTests < matlab.unittest.TestCase
    % Test that we can read artifacts from our own remote repository.
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
        destinationFolder = fullfile(tempdir(), 'destination');
    end
    
    methods (TestMethodSetup)
        
        function checkIfServerPresent(testCase)
            [isConnected, message] = rdtPingServer(testCase.testConfig);
            testCase.assumeTrue(isConnected, message);
        end
        
        function clearDestinationFolder(testCase)
            [~] = rmdir(testCase.destinationFolder, 's');
        end
    end
    
    methods (Test)
        
        function testFetchImage(testCase)
            remotePath = 'test-group-1';
            artifactId = 'image-artifact';
            version = '1';
            type = 'jpg';
            [data, artifact] = rdtReadArtifact(testCase.testConfig, ...
                remotePath, ...
                artifactId, ...
                'version', version, ...
                'type', type);
            
            testCase.assertNotEmpty(data);
            testCase.assertTrue(isnumeric(data));
            testCase.assertSize(data, [1080 1920 3]);
            
            testCase.assertNotEmpty(artifact);
            testCase.assertInstanceOf(artifact, 'struct');
        end
        
        function testFetchJson(testCase)
            remotePath = 'test-group-1';
            artifactId = 'json-artifact';
            version = '2';
            type = 'json';
            [data, artifact] = rdtReadArtifact(testCase.testConfig, ...
                remotePath, ...
                artifactId, ...
                'version', version, ...
                'type', type);
            
            testCase.assertNotEmpty(data);
            testCase.assertInstanceOf(data, 'struct');
            testCase.assertEqual(data.hello, 'world');
            
            testCase.assertNotEmpty(artifact);
            testCase.assertInstanceOf(artifact, 'struct');
        end
        
        function testFetchMatlab(testCase)
            remotePath = 'test-group-1';
            artifactId = 'matlab-artifact';
            version = '3';
            type = 'mat';
            [data, artifact] = rdtReadArtifact(testCase.testConfig, ...
                remotePath, ...
                artifactId, ...
                'version', version, ...
                'type', type);
            
            testCase.assertNotEmpty(data);
            testCase.assertInstanceOf(data, 'struct');
            testCase.assertEqual(data.foo, 'bar');
            
            testCase.assertNotEmpty(artifact);
            testCase.assertInstanceOf(artifact, 'struct');
        end
        
        function testFetchText(testCase)
            remotePath = 'test-group-1';
            artifactId = 'text-artifact';
            version = '4';
            type = 'txt';
            [data, artifact] = rdtReadArtifact(testCase.testConfig, ...
                remotePath, ...
                artifactId, ...
                'version', version, ...
                'type', type, ...
                'loadFunction', @RdtReadTests.loadText);
            
            testCase.assertNotEmpty(data);
            testCase.assertInstanceOf(data, 'char');
            testCase.assertEqual(data, 'This is a test artifact.');
            
            testCase.assertNotEmpty(artifact);
            testCase.assertInstanceOf(artifact, 'struct');
        end
        
        function testFetchMultiple(testCase)
            % look for all four test artifacts under one remote path
            artifacts(4) = rdtArtifact( ...
                'remotePath', 'test-group-1', ...
                'artifactId', 'text-artifact', ...
                'version', '4', ...
                'type', 'txt');
            artifacts(3) = rdtArtifact( ...
                'remotePath', 'test-group-1', ...
                'artifactId', 'matlab-artifact', ...
                'version', '3', ...
                'type', 'mat');
            artifacts(2) = rdtArtifact( ...
                'remotePath', 'test-group-1', ...
                'artifactId', 'json-artifact', ...
                'version', '2', ...
                'type', 'json');
            artifacts(1) = rdtArtifact( ...
                'remotePath', 'test-group-1', ...
                'artifactId', 'image-artifact', ...
                'version', '1', ...
                'type', 'jpg');
            
            % fetch all four
            [datas, fetchedArtifacts] = rdtReadArtifacts(testCase.testConfig, artifacts);
            
            % verify expected data
            testCase.assertNotEmpty(datas);
            testCase.assertInstanceOf(datas, 'cell');
            testCase.assertNumElements(datas, numel(artifacts));
            
            testCase.assertTrue(2 == exist(datas{4}, 'file'));
            testCase.assertEqual(datas{3}.foo, 'bar');
            testCase.assertEqual(datas{2}.hello, 'world');
            testCase.assertTrue(isnumeric(datas{1}));
            testCase.assertSize(datas{1}, [1080 1920 3]);
            
            % verify expected metadata
            testCase.assertNotEmpty(fetchedArtifacts);
            testCase.assertInstanceOf(fetchedArtifacts, 'struct');
            testCase.assertNumElements(fetchedArtifacts, numel(artifacts));
            for ii = 1:numel(artifacts)
                artifact = artifacts(ii);
                fetched = fetchedArtifacts(ii);
                
                % artifact id should match what was passed in
                testCase.assertEqual(fetched.artifactId, artifact.artifactId);
                
                % localPath should have been filled in
                testCase.assertEqual(exist(fetched.localPath, 'file'), 2);
            end
        end
        
        function testFetchLatestVersion(testCase)
            remotePath = 'test-group-1';
            artifactId = 'matlab-artifact';
            type = 'mat';
            [data, artifact] = rdtReadArtifact(testCase.testConfig, ...
                remotePath, ...
                artifactId, ...
                'type', type);
            
            testCase.assertNotEmpty(data);
            testCase.assertInstanceOf(data, 'struct');
            testCase.assertEqual(data.foo, 'bar');
            
            testCase.assertNotEmpty(artifact);
            testCase.assertInstanceOf(artifact, 'struct');
            testCase.assertEqual(artifact.artifactId, 'matlab-artifact');
        end
        
        function testFetchToDestinationDir(testCase)
            remotePath = 'test-group-1';
            artifactId = 'text-artifact';
            version = '4';
            type = 'txt';
            [data, artifact] = rdtReadArtifact(testCase.testConfig, ...
                remotePath, ...
                artifactId, ...
                'version', version, ...
                'type', type, ...
                'destinationFolder', testCase.destinationFolder, ...
                'loadFunction', @RdtReadTests.loadText);
            
            % destinationFolder must not break loadFunction
            testCase.assertNotEmpty(data);
            testCase.assertInstanceOf(data, 'char');
            testCase.assertEqual(data, 'This is a test artifact.');
            
            testCase.assertNotEmpty(artifact);
            testCase.assertInstanceOf(artifact, 'struct');
            
            % must create test folder and artifact with simple name
            simpleName = fullfile(testCase.destinationFolder, [artifactId '.' type]);
            testCase.assertEqual(artifact.localPath, simpleName);
            testCase.assertEqual(exist(testCase.destinationFolder, 'dir'), 7);
            testCase.assertEqual(exist(simpleName, 'file'), 2);
        end
    end
    
    methods (Static)
        function data = loadText(artifact)
            fid = fopen(artifact.localPath);
            data = fread(fid, '*char')';
            fclose(fid);
        end
    end
end
