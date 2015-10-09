classdef RdtQueryTests < matlab.unittest.TestCase
    % Test that we can make Archiva RESTful queries.
    % These tests assume that we have an Archiva server running on
    % localhost with expected user credentials and repository contents.
    % If the expected server can't be found, skips these tests.
    
    properties (Access = private)
        testConfig = rdtConfiguration( ...
            'serverUrl', 'http://localhost:8080', ...
            'repositoryName', 'test-repository', ...
            'username', 'admin', ...
            'password', 'pa55w0rd', ...
            'requestMediaType', 'application/json', ...
            'acceptMediaType', 'application/json');
        expectedGroupIds = {'test-group1', 'test-group2'};
        expectedArtifactIds = {'test-artifact1', 'test-artifact2'};
        expectedVersions = {'1', '2'};
        expectedTypes = {'txt', 'mat'};
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
        
        function testListGroups(testCase)
            groupIds = rdtListGroups(testCase.testConfig);
            groupIds = sort(groupIds);
            testCase.assertEqual(groupIds, testCase.expectedGroupIds);
        end
        
        function testListArtifacts(testCase)
            artifacts = rdtListArtifacts('test-group1', testCase.testConfig);
            testCase.checkExpectedArtifacts(artifacts);
            
            artifacts = rdtListArtifacts('test-group2', testCase.testConfig);
            testCase.checkExpectedArtifacts(artifacts);
        end
        
    end
    
    methods (Access=private)
        function checkExpectedArtifacts(testCase, artifacts)
            testCase.assertNotEmpty(artifacts);
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertSize(artifacts, [1,2]);
            testCase.assertThat(artifacts, matlab.unittest.constraints.HasField('artifactId'));
            
            artifactIds = sort({artifacts.artifactId});
            testCase.assertEqual(artifactIds, testCase.expectedArtifactIds);
        end
    end
end
