classdef RdtQueryTests < matlab.unittest.TestCase
    % Test that we can make Archiva RESTful queries.
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
        expectedRemotePaths = {'test-group-1', 'test-group-2'};
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
                rdtRequestWeb(pingConfig, pingPath);
            catch ex
                exception = ex;
            end
            testCase.assumeEmpty(exception);
        end
        
    end
    
    methods (Test)
        
        function testListRemotePaths(testCase)
            [remotePaths, repositoryName] = rdtListRemotePaths(testCase.testConfig);
            testCase.assertTrue(any(strcmp(remotePaths, testCase.expectedRemotePaths{1})));
            testCase.assertTrue(any(strcmp(remotePaths, testCase.expectedRemotePaths{2})));
            testCase.assertEqual(repositoryName, testCase.testConfig.repositoryName);
        end
        
        function testListArtifacts(testCase)
            artifacts = rdtListArtifacts(testCase.testConfig, 'test-group-1');
            testCase.checkPathArtifacts(artifacts, 'test-group-1');
            
            artifacts = rdtListArtifacts(testCase.testConfig, 'test-group-2');
            testCase.checkPathArtifacts(artifacts, 'test-group-2');
        end
        
        function testListArtifactsPageSize(testCase)
            % large page size, return all results
            artifacts = rdtListArtifacts(testCase.testConfig, 'test-group-1', ...
                'pageSize', 1e6);
            testCase.assertNotEmpty(artifacts);
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 4);
            
            % small page size, restrict results
            % Archiva list seems not to obey pageSize exact value
            % Nevertheless, pageSize ought to have some effect.
            artifacts = rdtListArtifacts(testCase.testConfig, 'test-group-1', ...
                'pageSize', 2);
            testCase.assertNotEmpty(artifacts);
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertLessThan(numel(artifacts), 4);
        end
        
        function testSearchArtifactsPageSize(testCase)
            % large page size, return all results
            artifacts = rdtSearchArtifacts(testCase.testConfig, 'test', ...
                'pageSize', 1e6);
            testCase.assertNotEmpty(artifacts);
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 8);
            
            % small page size, restrict results
            % Archiva search seems not to obey pageSize exact value
            % Furthermore, our rdtSearchArtifacts() may make multiple
            % requests, each with its own "page" of results.
            % Nevertheless, pageSize ought to have some effect.
            artifacts = rdtSearchArtifacts(testCase.testConfig, 'test', ...
                'pageSize', 2);
            testCase.assertNotEmpty(artifacts);
            testCase.assertInstanceOf(artifacts, 'struct');            
            testCase.assertLessThan(numel(artifacts), 8);
        end
        
        function testSearchEmptyTerms(testCase)
            artifacts = rdtSearchArtifacts(testCase.testConfig, '');
            testCase.assertEmpty(artifacts);
        end
        
        function testSearchHitNone(testCase)
            artifacts = rdtSearchArtifacts(testCase.testConfig, 'nonononotamatch');
            testCase.assertEmpty(artifacts);
        end
        
        function testSearchHitAll(testCase)
            artifacts = rdtSearchArtifacts(testCase.testConfig, 'test');
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 8);
        end
        
        function testSearchRestrictRemotePath(testCase)
            artifacts = rdtSearchArtifacts(testCase.testConfig, 'test', ...
                'remotePath', 'test-group-1');
            testCase.checkPathArtifacts(artifacts, 'test-group-1');
        end
        
        function testSearchRestrictArtifactId(testCase)
            artifacts = rdtSearchArtifacts(testCase.testConfig, 'test', ...
                'artifactId', 'text-artifact');
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 2);
            
            artifactIds = {artifacts.artifactId};
            testCase.assertEqual(artifactIds, {'text-artifact', 'text-artifact'});
        end
        
        function testSearchRestrictVersion(testCase)
            artifacts = rdtSearchArtifacts(testCase.testConfig, 'test', ...
                'version', '1');
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 2);
            
            versions = {artifacts.version};
            testCase.assertEqual(versions, {'1', '1'});
        end
        
        function testSearchRestrictType(testCase)
            artifacts = rdtSearchArtifacts(testCase.testConfig, 'test', ...
                'type', 'mat');
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 2);
            
            types = {artifacts.type};
            testCase.assertEqual(types, {'mat', 'mat'});
        end
        
        function testSearchRestrictUniqueArtifact(testCase)
            artifacts = rdtSearchArtifacts(testCase.testConfig, 'test', ...
                'remotePath', 'test-group-1', ...
                'artifactId', 'image-artifact', ...
                'version', '1', ...
                'type', 'jpg');
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 1);
            
            testCase.assertEqual(artifacts.remotePath, 'test-group-1');
            testCase.assertEqual(artifacts.artifactId, 'image-artifact');
            testCase.assertEqual(artifacts.version, '1');
            testCase.assertEqual(artifacts.type, 'jpg');
        end
        
        function testSearchRestrictNoArtifact(testCase)
            artifacts = rdtSearchArtifacts(testCase.testConfig, 'test', ...
                'remotePath', 'test-group-1', ...
                'artifactId', 'image-artifact', ...
                'version', '2', ...
                'type', 'jpg');
            testCase.assertEmpty(artifacts);
        end
        
        function testListRestrictArtifactId(testCase)
            artifacts = rdtListArtifacts(testCase.testConfig, 'test-group-1', ...
                'artifactId', 'text-artifact');
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 1);
            
            testCase.assertEqual(artifacts.artifactId, 'text-artifact');
        end
        
        function testListRestrictVersion(testCase)
            artifacts = rdtListArtifacts(testCase.testConfig, 'test-group-1', ...
                'version', '1');
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 1);
            
            testCase.assertEqual(artifacts.version, '1');
        end
        
        function testListRestrictType(testCase)
            artifacts = rdtListArtifacts(testCase.testConfig, 'test-group-1', ...
                'type', 'mat');
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 1);
            
            testCase.assertEqual(artifacts.type, 'mat');
        end
        
        function testListRestrictUniqueArtifact(testCase)
            artifacts = rdtListArtifacts(testCase.testConfig, 'test-group-1', ...
                'artifactId', 'image-artifact', ...
                'version', '1', ...
                'type', 'jpg');
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 1);
            
            testCase.assertEqual(artifacts.remotePath, 'test-group-1');
            testCase.assertEqual(artifacts.artifactId, 'image-artifact');
            testCase.assertEqual(artifacts.version, '1');
            testCase.assertEqual(artifacts.type, 'jpg');
        end
        
        function testListRestrictNoArtifact(testCase)
            artifacts = rdtListArtifacts(testCase.testConfig, 'test-group-1', ...
                'remotePath', 'test-group-1', ...
                'artifactId', 'image-artifact', ...
                'version', '2', ...
                'type', 'jpg');
            testCase.assertEmpty(artifacts);
        end
        
    end
    
    methods (Access=private)
        function checkPathArtifacts(testCase, artifacts, remotePath)
            testCase.assertNotEmpty(artifacts);
            testCase.assertInstanceOf(artifacts, 'struct');
            testCase.assertNumElements(artifacts, 4);
            
            remotePaths = sort({artifacts.remotePath});
            testCase.assertEqual(remotePaths, {remotePath, remotePath, remotePath, remotePath});
            
            artifactIds = sort({artifacts.artifactId});
            testCase.assertEqual(artifactIds, testCase.expectedArtifactIds);
            
            versions = sort({artifacts.version});
            testCase.assertEqual(versions, testCase.expectedVersions);
            
            types = sort({artifacts.type});
            testCase.assertEqual(types, testCase.expectedTypes);
        end
    end
end
