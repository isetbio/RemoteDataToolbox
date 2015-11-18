classdef RdtReadMavenCentralTests < matlab.unittest.TestCase
    % Test that we can read artifacts from a general-purpose Maven
    % repository, regardless of how we configure our own server.  These
    % tests rely on Maven Central, which is a popular, public Maven
    % repository:
    %   https://repo1.maven.org/maven2/
    
    properties (Access = private)
        testConfig = rdtConfiguration( ...
            'repositoryUrl', 'https://repo1.maven.org/maven2/', ...
            'username', '', ...
            'password', '', ...
            'acceptMediaType', 'text/html');
    end
    
    methods (Test)
        
        function testFetchMavenCentral(testCase)
            % fetch an artifact related to the popular "ant" tool
            remotePath = 'ant';
            artifactId = 'ant-commons-logging';
            version = '1.6.5';
            type = 'pom';
            [data, artifact] = rdtReadArtifact(remotePath, ...
                artifactId, ...
                version, ...
                type, ...
                testCase.testConfig);
            
            testCase.assertNotEmpty(data);
            testCase.assertNotEmpty(artifact);
            testCase.assertInstanceOf(artifact, 'struct');
            
            testCase.assertEqual(exist(artifact.localPath, 'file'), 2);
        end
    end
end
