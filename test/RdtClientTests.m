classdef RdtClientTests < matlab.unittest.TestCase
    % Test the client utility class to make sure its API works.
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
        
        function testWorkingRemotePath(testCase)
            client = RdtClient(testCase.testConfig);
            
            testCase.assertEqual(client.pwrp(), '');
            
            client.crp('foo');
            testCase.assertEqual(client.pwrp(), 'foo');
            
            client.crp('bar');
            testCase.assertEqual(client.pwrp(), 'foo/bar');
            
            client.crp('..');
            testCase.assertEqual(client.pwrp(), 'foo');
            
            client.crp('/baz');
            testCase.assertEqual(client.pwrp(), 'baz');
            
            client.crp('/');
            testCase.assertEqual(client.pwrp(), '');
            
            client.crp('..');
            testCase.assertEqual(client.pwrp(), '');
        end
        
        function testListRemotePaths(testCase)
            client = RdtClient(testCase.testConfig);
            remotePaths = client.listRemotePaths();
            testCase.assertNotEmpty(remotePaths);
        end
        
        function testListArtifacts(testCase)
            client = RdtClient(testCase.testConfig);
            
            % all artifacts
            workingArtifacts = client.listArtifacts();
            explicitArtifacts = client.listArtifacts('remotePath', '');
            testCase.assertNotEmpty(workingArtifacts);
            testCase.assertEqual(workingArtifacts, explicitArtifacts);
            
            % some artifacts
            client.crp('test-group-1');
            workingArtifacts = client.listArtifacts();
            explicitArtifacts = client.listArtifacts('remotePath', 'test-group-1');
            testCase.assertNumElements(workingArtifacts, 4);
            testCase.assertEqual(workingArtifacts, explicitArtifacts);
            
            % no artifacts
            client.crp('nonono/thou/art/not/a/path');
            workingArtifacts = client.listArtifacts();
            explicitArtifacts = client.listArtifacts('remotePath', 'nonono/thou/art/not/a/path');
            testCase.assertEmpty(workingArtifacts);
            testCase.assertEqual(workingArtifacts, explicitArtifacts);
        end
        
        function testSearchArtifacts(testCase)
            client = RdtClient(testCase.testConfig);
            
            % all test artifacts
            testArtifacts = client.searchArtifacts('test-group');
            testCase.assertNumElements(testArtifacts, 8);
            
            % half the test artifacts
            client.crp('/test-group-1');
            testArtifacts = client.searchArtifacts('test');
            testCase.assertNumElements(testArtifacts, 4);
            
            % no artifacts
            client.crp('/nonono');
            testArtifacts = client.searchArtifacts('test');
            testCase.assertEmpty(testArtifacts);
            
            % one test artifact
            client.crp('/nonono');
            testArtifacts = client.searchArtifacts('test', ...
                'remotePath', 'test-group-1', ...
                'artifactId', 'image-artifact', ...
                'version', '1', ...
                'type', 'jpg');
            testCase.assertNumElements(testArtifacts, 1);
        end
        
        function testReadArtifact(testCase)
            client = RdtClient(testCase.testConfig);
            
            % use pwrp
            client.crp('test-group-1');
            [data, artifact] = client.readArtifact('image-artifact', ...
                'type', 'jpg');
            testCase.assertNotEmpty(data);
            testCase.assertNotEmpty(artifact);
            
            % explicit remote path
            client.crp('test-group-1');
            [data, artifact] = client.readArtifact('image-artifact', ...
                'type', 'jpg', ...
                'remotePath', 'test-group-2');
            testCase.assertNotEmpty(data);
            testCase.assertNotEmpty(artifact);
        end
        
        function testReadArtifacts(testCase)
            client = RdtClient(testCase.testConfig);
            
            % test artifacts from pwrp()
            client.crp('test-group-2');
            [datas, artifacts] = client.readArtifacts();
            testCase.assertNumElements(datas, 4);
            testCase.assertNumElements(artifacts, 4);
            
            % test artifacts from explicit remote path
            [datas, artifacts] = client.readArtifacts('test-group-1');
            testCase.assertNumElements(datas, 4);
            testCase.assertNumElements(artifacts, 4);
            
            % artifacts from explicit struct of metadata
            explicitArtifacts = client.listArtifacts('remotePath', 'test-group-1');
            [datas, artifacts] = client.readArtifacts(explicitArtifacts);
            testCase.assertNumElements(datas, 4);
            testCase.assertNumElements(artifacts, 4);
        end
        
        function testPublishArtifact(testCase)
            client = RdtClient(testCase.testConfig);
            
            % publish random artifact to pwrp()
            testArtifactData = rand(42, 42);
            save(testCase.testArtifactFile, 'testArtifactData');
            client.crp('publish-group/subgroup');
            artifact = client.publishArtifact(testCase.testArtifactFile);
            testCase.verifyPublishedData(client, testArtifactData, 'temp-artifact', artifact);
            
            % publish the artifact to explicit folder and rename it
            testArtifactData = rand(42, 42);
            save(testCase.testArtifactFile, 'testArtifactData');
            artifact = client.publishArtifact(testCase.testArtifactFile, ...
                'remotePath', 'publish-group/subgroup/subsubgroup', ...
                'artifactId', 'the-answer', ...
                'version', '42');
            testCase.verifyPublishedData(client, testArtifactData, 'the-answer', artifact);
        end
        
        function testPublishArtifacts(testCase)
            client = RdtClient(testCase.testConfig);
            
            % choose the testArtifacts from this folder
            thisFolder = fileparts(mfilename('fullpath'));
            artifactFolder = fullfile(thisFolder, 'testArtifacts');
            
            % publish all to pwrp()
            client.crp('publish-multiple-group/subgroup');
            artifacts = client.publishArtifacts(artifactFolder);
            testCase.verifyPublishedFolder(artifacts, artifactFolder, client.pwrp());
            
            % restrict to the txt artifact
            artifacts = client.publishArtifacts(artifactFolder, ...
                'remotePath', 'publish-multiple-group/subgroup/subsubgroup', ...
                'type', 'txt');
            testCase.assertNumElements(artifacts, 2);
            testCase.verifyPublishedFolder(artifacts, ...
                artifactFolder, ...
                'publish-multiple-group/subgroup/subsubgroup');
        end
    end
    
    methods
        function verifyPublishedData(testCase, client, testArtifactData, artifactId, artifact)
            testCase.assertNotEmpty(artifact);
            testCase.assertEqual(artifact.artifactId, artifactId);
            
            % fetch artifact and verify the latest data
            datas = client.readArtifacts(artifact);
            testCase.assertNotEmpty(datas);
            testCase.assertInstanceOf(datas, 'cell');
            testCase.assertNumElements(datas, 1);
            
            data = datas{1};
            testCase.assertInstanceOf(data, 'struct');
            testCase.assertTrue(isnumeric(data.testArtifactData));
            testCase.assertEqual(data.testArtifactData, testArtifactData);
        end
        
        function verifyPublishedFolder(testCase, artifacts, artifactFolder, remotePath)
            testCase.assertNotEmpty(artifacts);
            testCase.assertInstanceOf(artifacts, 'struct');
            
            for ii = 1:numel(artifacts)
                artifact = artifacts(ii);
                originalFile = fullfile(artifactFolder, ...
                    [artifact.artifactId '.' artifact.type]);
                testCase.assertEqual(exist(originalFile, 'file'), 2);
                testCase.assertEqual(artifact.remotePath, remotePath);
            end
        end
    end
end