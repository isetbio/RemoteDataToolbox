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
        expectedTypes = {'mat', 'txt'};
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
            testCase.checkGroupArtifacts(artifacts, 'test-group1');
            
            artifacts = rdtListArtifacts('test-group2', testCase.testConfig);
            testCase.checkGroupArtifacts(artifacts, 'test-group2');
        end
        
        function testSearchEmptyTerms(testCase)
            artifacts = rdtSearchArtifacts('', '', '', '', '', testCase.testConfig);
            testCase.assertEmpty(artifacts);
        end
        
        function testSearchHitNone(testCase)
            artifacts = rdtSearchArtifacts('nonononotamatch', '', '', '', '', testCase.testConfig);
            testCase.assertEmpty(artifacts);
        end
        
        function testSearchHitAll(testCase)
            artifacts = rdtSearchArtifacts('test', '', '', '', '', testCase.testConfig);
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 4);
        end
        
        function testSearchRestrictGroupId(testCase)
            artifacts = rdtSearchArtifacts('test', 'test-group1', '', '', '', testCase.testConfig);
            testCase.checkGroupArtifacts(artifacts, 'test-group1');
        end
        
        function testSearchRestrictArtifactId(testCase)
            artifacts = rdtSearchArtifacts('test', '', 'test-artifact1', '', '', testCase.testConfig);
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 2);
            
            artifactIds = {artifacts.artifactId};
            testCase.assertEqual(artifactIds, {'test-artifact1', 'test-artifact1'});
        end
        
        function testSearchRestrictVersion(testCase)
            artifacts = rdtSearchArtifacts('test', '', '', '1', '', testCase.testConfig);
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 2);
            
            versions = {artifacts.version};
            testCase.assertEqual(versions, {'1', '1'});
        end
        
        function testSearchRestrictType(testCase)
            artifacts = rdtSearchArtifacts('test', '', '', '', 'mat', testCase.testConfig);
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 2);
            
            types = {artifacts.type};
            testCase.assertEqual(types, {'mat', 'mat'});
        end
        
        function testSearchRestrictUniqueArtifact(testCase)
            artifacts = rdtSearchArtifacts('test', 'test-group1', 'test-artifact1', '1', 'txt', testCase.testConfig);
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 1);
            
            testCase.assertEqual(artifacts.groupId, 'test-group1');
            testCase.assertEqual(artifacts.artifactId, 'test-artifact1');
            testCase.assertEqual(artifacts.version, '1');
            testCase.assertEqual(artifacts.type, 'txt');
        end
        
        function testSearchRestrictNoArtifact(testCase)
            artifacts = rdtSearchArtifacts('test', 'test-group1', 'test-artifact1', '2', 'txt', testCase.testConfig);
            testCase.assertEmpty(artifacts);
        end
        
    end
    
    methods (Access=private)
        function checkGroupArtifacts(testCase, artifacts, groupId)
            testCase.assertNotEmpty(artifacts);
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 2);
            
            groupIds = sort({artifacts.groupId});
            testCase.assertEqual(groupIds, {groupId, groupId});
            
            artifactIds = sort({artifacts.artifactId});
            testCase.assertEqual(artifactIds, testCase.expectedArtifactIds);
            
            versions = sort({artifacts.version});
            testCase.assertEqual(versions, testCase.expectedVersions);
            
            types = sort({artifacts.type});
            testCase.assertEqual(types, testCase.expectedTypes);
        end
    end
end
