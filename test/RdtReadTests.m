classdef RdtReadTests < matlab.unittest.TestCase
    % Test that we can read artifacts with expected content from our own
    % Maven server.  These tests assume that we have a Maven server
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
    
    methods (Test)
        
        function testFetchImage(testCase)
            groupId = 'test-group-1';
            artifactId = 'image-artifact';
            version = '1';
            type = 'jpg';
            [data, artifact] = rdtReadArtifact(groupId, ...
                artifactId, ...
                version, ...
                type, ...
                testCase.testConfig);
            
            testCase.assertNotEmpty(data);
            testCase.assertTrue(isnumeric(data));
            testCase.assertSize(data, [1080 1920 3]);
            
            testCase.assertNotEmpty(artifact);
            testCase.assertInstanceOf(artifact, 'struct');
        end
        
        function testFetchJson(testCase)
            groupId = 'test-group-1';
            artifactId = 'json-artifact';
            version = '2';
            type = 'json';
            [data, artifact] = rdtReadArtifact(groupId, ...
                artifactId, ...
                version, ...
                type, ...
                testCase.testConfig);
            
            testCase.assertNotEmpty(data);
            testCase.assertInstanceOf(data, 'struct');
            testCase.assertEqual(data.hello, 'world');
            
            testCase.assertNotEmpty(artifact);
            testCase.assertInstanceOf(artifact, 'struct');
        end
        
        function testFetchMatlab(testCase)
            groupId = 'test-group-1';
            artifactId = 'matlab-artifact';
            version = '3';
            type = 'mat';
            [data, artifact] = rdtReadArtifact(groupId, ...
                artifactId, ...
                version, ...
                type, ...
                testCase.testConfig);
            
            testCase.assertNotEmpty(data);
            testCase.assertInstanceOf(data, 'struct');
            testCase.assertEqual(data.foo, 'bar');
            
            testCase.assertNotEmpty(artifact);
            testCase.assertInstanceOf(artifact, 'struct');
        end
        
        function testFetchText(testCase)
            groupId = 'test-group-1';
            artifactId = 'text-artifact';
            version = '4';
            type = 'txt';
            [data, artifact] = rdtReadArtifact(groupId, ...
                artifactId, ...
                version, ...
                type, ...
                testCase.testConfig);
            
            testCase.assertNotEmpty(data);
            testCase.assertInstanceOf(data, 'char');
            testCase.assertEqual(data, 'This is a test artifact.');
            
            testCase.assertNotEmpty(artifact);
            testCase.assertInstanceOf(artifact, 'struct');
        end
        
        function testFetchMultiple(testCase)
            % look for all four test artifacts in one group
            artifacts(4) = rdtArtifact( ...
                'groupId', 'test-group-1', ...
                'artifactId', 'text-artifact', ...
                'version', '4', ...
                'type', 'txt');
            artifacts(3) = rdtArtifact( ...
                'groupId', 'test-group-1', ...
                'artifactId', 'matlab-artifact', ...
                'version', '3', ...
                'type', 'mat');
            artifacts(2) = rdtArtifact( ...
                'groupId', 'test-group-1', ...
                'artifactId', 'json-artifact', ...
                'version', '2', ...
                'type', 'json');
            artifacts(1) = rdtArtifact( ...
                'groupId', 'test-group-1', ...
                'artifactId', 'image-artifact', ...
                'version', '1', ...
                'type', 'jpg');
            
            % fetch all four
            [datas, fetchedArtifacts] = rdtReadArtifacts(artifacts, testCase.testConfig);
            
            % verify expected data
            testCase.assertNotEmpty(datas);
            testCase.assertInstanceOf(datas, 'cell');
            testCase.assertNumElements(datas, numel(artifacts));
            
            testCase.assertEqual(datas{4}, 'This is a test artifact.');
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
            groupId = 'test-group-1';
            artifactId = 'matlab-artifact';
            type = 'mat';
            [data, artifact] = rdtReadArtifact(groupId, ...
                artifactId, ...
                '', ...
                type, ...
                testCase.testConfig);
            
            testCase.assertNotEmpty(data);
            testCase.assertInstanceOf(data, 'struct');
            testCase.assertEqual(data.foo, 'bar');
            
            testCase.assertNotEmpty(artifact);
            testCase.assertInstanceOf(artifact, 'struct');
            testCase.assertEqual(artifact.artifactId, 'matlab-artifact');
        end
    end
end
