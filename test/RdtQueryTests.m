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
        expectedGroupIds = {'test-group-1', 'test-group-2'};
        expectedArtifactIds = {'image-artifact', 'json-artifact', 'matlab-artifact', 'text-artifact'};
        expectedVersions = {'1', '2', '3', '4'};
        expectedTypes = {'jpg', 'json', 'mat', 'txt'};
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
            [groupIds, repositoryName] = rdtListGroups(testCase.testConfig);
            testCase.assertTrue(any(strcmp(groupIds, testCase.expectedGroupIds{1})));
            testCase.assertTrue(any(strcmp(groupIds, testCase.expectedGroupIds{2})));
            testCase.assertEqual(repositoryName, testCase.testConfig.repositoryName);
        end
        
        function testListArtifacts(testCase)
            artifacts = rdtListArtifacts('test-group-1', testCase.testConfig);
            testCase.checkGroupArtifacts(artifacts, 'test-group-1');
            
            artifacts = rdtListArtifacts('test-group-2', testCase.testConfig);
            testCase.checkGroupArtifacts(artifacts, 'test-group-2');
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
            testCase.assertNumElements(artifacts, 8);
        end
        
        function testSearchRestrictGroupId(testCase)
            artifacts = rdtSearchArtifacts('test', 'test-group-1', '', '', '', testCase.testConfig);
            testCase.checkGroupArtifacts(artifacts, 'test-group-1');
        end
        
        function testSearchRestrictArtifactId(testCase)
            artifacts = rdtSearchArtifacts('test', '', 'text-artifact', '', '', testCase.testConfig);
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 2);
            
            artifactIds = {artifacts.artifactId};
            testCase.assertEqual(artifactIds, {'text-artifact', 'text-artifact'});
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
            artifacts = rdtSearchArtifacts('test', 'test-group-1', 'image-artifact', '1', 'jpg', testCase.testConfig);
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 1);
            
            testCase.assertEqual(artifacts.groupId, 'test-group-1');
            testCase.assertEqual(artifacts.artifactId, 'image-artifact');
            testCase.assertEqual(artifacts.version, '1');
            testCase.assertEqual(artifacts.type, 'jpg');
        end
        
        function testSearchRestrictNoArtifact(testCase)
            artifacts = rdtSearchArtifacts('test', 'test-group-1', 'image-artifact', '2', 'jpg', testCase.testConfig);
            testCase.assertEmpty(artifacts);
        end
        
    end
    
    methods (Access=private)
        function checkGroupArtifacts(testCase, artifacts, groupId)
            testCase.assertNotEmpty(artifacts);
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 4);
            
            groupIds = sort({artifacts.groupId});
            testCase.assertEqual(groupIds, {groupId, groupId, groupId, groupId});
            
            artifactIds = sort({artifacts.artifactId});
            testCase.assertEqual(artifactIds, testCase.expectedArtifactIds);
            
            versions = sort({artifacts.version});
            testCase.assertEqual(versions, testCase.expectedVersions);
            
            types = sort({artifacts.type});
            testCase.assertEqual(types, testCase.expectedTypes);
        end
    end
end
