classdef RdtFetchTests < matlab.unittest.TestCase
    % Test that we can fetch artifacts with expected content from a our own
    % Maven server.  These tests assume that we have an Archiva server
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
    end
end
