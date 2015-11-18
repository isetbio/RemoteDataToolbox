classdef RdtPublishTests < matlab.unittest.TestCase
    % Test that we can publish artifacts with expected content to our
    % own remote repository.  These tests attempt to connect to a public
    % Archiva server called brainard-archiva, using expected test
    % credentials and repository contents. If the expected server can't be
    % found, skips these tests.
    
    properties (Access = private)
        testConfig = rdtConfiguration( ...
            'serverUrl', 'http://52.32.77.154', ...
            'repositoryUrl', 'http://52.32.77.154/repository/test-repository', ...
            'repositoryName', 'test-repository', ...
            'username', 'test', ...
            'password', 'test123', ...
            'requestMediaType', 'application/json', ...
            'acceptMediaType', 'application/json');
        testArtifactFile = fullfile(tempdir(), 'temp-artifact.mat');
    end
    
    methods (TestMethodSetup)
        
        function checkIfServerPresent(testCase)
            exception = [];
            try
                pingConfig = testCase.testConfig;
                pingConfig.acceptMediaType = 'text/plain';
                pingPath = '/restServices/archivaServices/pingService/ping';
                rdtRequestWeb(pingPath, '', '', pingConfig);
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
            artifact = rdtPublishArtifact(testCase.testArtifactFile, ...
                'publish-group', ...
                'publish-id', ...
                '42', ...
                testCase.testConfig);
            
            testCase.assertNotEmpty(artifact);
            testCase.assertInstanceOf(artifact, 'struct');
            testCase.assertEqual(artifact.artifactId, 'publish-id');
            
            % fetch artifact and verify the latest data
            datas = rdtReadArtifacts(artifact, testCase.testConfig);
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
            
            artifacts = rdtPublishArtifacts(artifactFolder, ...
                'publish-multiple-group', ...
                '123', ...
                '', ...
                testCase.testConfig);
            
            testCase.assertNotEmpty(artifacts);
            testCase.assertInstanceOf(artifacts, 'struct');
            
            for ii = 1:numel(artifacts)
                originalFile = fullfile(artifactFolder, ...
                    [artifacts(ii).artifactId '.' artifacts(ii).type]);
                testCase.assertEqual(exist(originalFile, 'file'), 2);
            end
        end
        
        function testPublishMultipleByType(testCase)
            % choose the testArtifacts from this folder
            thisFolder = fileparts(mfilename('fullpath'));
            artifactFolder = fullfile(thisFolder, 'testArtifacts');
            
            artifacts = rdtPublishArtifacts(artifactFolder, ...
                'publish-multiple-group', ...
                '123', ...
                'txt', ...
                testCase.testConfig);
            
            testCase.assertNotEmpty(artifacts);
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 1);
            testCase.assertEqual(artifacts.type, 'txt');
            testCase.assertEqual(artifacts.artifactId, 'text-artifact');
        end
    end
end