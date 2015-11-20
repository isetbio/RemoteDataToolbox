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
            'acceptMediaType', 'application/json');
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
    end
end