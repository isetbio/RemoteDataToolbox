classdef RdtPublishTests < matlab.unittest.TestCase
    % Test that we can publish artifacts with expected content to our
    % own Maven server.  These tests assume that we have a Maven server
    % running on localhost with expected user credentials and repository
    % contents. If the expected server can't be found, skips these tests.
    
    properties (Access = private)
        testConfig = rdtConfiguration( ...
            'serverUrl', 'http://localhost:8080', ...
            'repositoryName', 'test-repository', ...
            'username', 'admin', ...
            'password', 'pa55w0rd', ...
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
    end
end