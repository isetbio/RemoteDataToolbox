classdef RdtPublishTests < matlab.unittest.TestCase
    % Test that we can publish artifacts to our own remote repository.
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
            exception = [];
            try
                pingConfig = testCase.testConfig;
                pingConfig.acceptMediaType = 'text/plain';
                pingPath = '/restServices/archivaServices/pingService/ping';
                rdtRequestWeb(pingConfig, pingPath);
            catch ex
                exception = ex;
            end
            testCase.assumeEmpty(exception);
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
        function testPublishTestArtifact(testCase)
            % create a random test artifact
            testArtifactData = rand(7, 101);
            save(testCase.testArtifactFile, 'testArtifactData');
            
            % publish the artifact
            artifact = rdtPublishArtifact(testCase.testConfig, ...
                testCase.testArtifactFile, ...
                'publish-group', ...
                'artifactId', 'publish-id', ...
                'version', '42', ...
                'name', 'Dr. Test', ...
                'description', 'This is only a test.');
            
            testCase.assertNotEmpty(artifact);
            testCase.assertInstanceOf(artifact, 'struct');
            testCase.assertEqual(artifact.artifactId, 'publish-id');
            testCase.assertEqual(artifact.name, 'Dr. Test');
            testCase.assertEqual(artifact.description, 'This is only a test.');
            
            % fetch artifact and verify the latest data
            datas = rdtReadArtifacts(testCase.testConfig, artifact);
            testCase.assertNotEmpty(datas);
            testCase.assertInstanceOf(datas, 'cell');
            testCase.assertNumElements(datas, 1);
            
            data = datas{1};
            testCase.assertInstanceOf(data, 'struct');
            testCase.assertTrue(isnumeric(data.testArtifactData));
            testCase.assertEqual(data.testArtifactData, testArtifactData);
        end
        
        function testPublishMultiple(testCase)
            % choose the testArtifacts from this folder
            thisFolder = fileparts(mfilename('fullpath'));
            artifactFolder = fullfile(thisFolder, 'testArtifacts');
            
            artifacts = rdtPublishArtifacts(testCase.testConfig, ...
                artifactFolder, ...
                'publish-multiple-group', ...
                'version', '123', ...
                'name', 'Test', ...
                'description', 'This is one of several tests.');
            
            testCase.assertNotEmpty(artifacts);
            testCase.assertInstanceOf(artifacts, 'struct');
            
            for ii = 1:numel(artifacts)
                originalFile = fullfile(artifactFolder, ...
                    [artifacts(ii).artifactId '.' artifacts(ii).type]);
                testCase.assertEqual(exist(originalFile, 'file'), 2);
                
                testCase.assertEqual(artifacts(ii).name, 'Test');
                testCase.assertEqual(artifacts(ii).description, 'This is one of several tests.');
            end
            
            % make sure we can list these
            listed = rdtListArtifacts(testCase.testConfig, ...
                'publish-multiple-group', ...
                'version', '123');
            testCase.assertNumElements(listed, numel(artifacts));

            % make sure we can find these
            found = rdtSearchArtifacts(testCase.testConfig, ...
                'publish-multiple-group', ...
                'version', '123');
            testCase.assertNumElements(found, numel(artifacts));
        end
        
        function testPublishMultipleByType(testCase)
            % choose the testArtifacts from this folder
            thisFolder = fileparts(mfilename('fullpath'));
            artifactFolder = fullfile(thisFolder, 'testArtifacts');
            
            artifacts = rdtPublishArtifacts(testCase.testConfig, ...
                artifactFolder, ...
                'publish-multiple-group', ...
                'version', '123', ...
                'type', 'txt');
            
            testCase.assertNotEmpty(artifacts);
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 2);
            
            types = {artifacts.type};
            testCase.assertEqual(types, {'txt', 'txt'});
            
            artifactIds = {artifacts.artifactId};
            testCase.assertTrue(any(strcmp('text-artifact', artifactIds)));
            testCase.assertTrue(any(strcmp('multiple-flavor-test', artifactIds)));
        end
    end
end