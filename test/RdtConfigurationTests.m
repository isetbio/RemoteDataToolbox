classdef RdtConfigurationTests < matlab.unittest.TestCase
    
    methods (Test)
        
        function testDeault(testCase)
            testCase.sanityCheckConfiguration(rdtConfiguration());
        end
        
        function testFromTestProject(testCase)
            configuration = rdtConfiguration('test');
            testCase.assertEqual('test-repository', configuration.repositoryName);
        end
        
        function testFromAlternateProject(testCase)
            configuration = rdtConfiguration('test-alternate');
            testCase.assertEqual('alternate-repository-name', configuration.repositoryName);
        end
        
        function testFromExplicitFile(testCase)
            configFile = which('rdt-config-test-alternate.json');
            configuration = rdtConfiguration(configFile);
            testCase.assertEqual('alternate-repository-name', configuration.repositoryName);
        end
        
        function testExplicitFileMustBeJson(testCase)
            existingFile = 'RdtConfigurationTests';
            configuration = rdtConfiguration(existingFile);
            testCase.assertEmpty(configuration.repositoryName);
        end
        
        function testFromStructArg(testCase)
            configArgs.repositoryName = 'random-repository-name';
            configuration = rdtConfiguration(configArgs);
            testCase.assertEqual('random-repository-name', configuration.repositoryName);
        end
        
        function testFromNameValueArgs(testCase)
            configuration = rdtConfiguration('repositoryName', 'silly-repository-name');
            testCase.assertEqual('silly-repository-name', configuration.repositoryName);
        end
        
        function testGarbageInput(testCase)
            testCase.sanityCheckConfiguration(rdtConfiguration(42));
            testCase.sanityCheckConfiguration(rdtConfiguration(nan(10)));
            testCase.sanityCheckConfiguration(rdtConfiguration({'blergh'}));
            testCase.sanityCheckConfiguration(rdtConfiguration('I don''t exist.file'));
            testCase.sanityCheckConfiguration(rdtConfiguration([]));
        end
        
        function testWriteAndReadFile(testCase)
            configuration = rdtConfiguration( ...
                'serverUrl', 'this-is-a-test');
            projectName = 'this-is-a-test';
            folder = tempdir();
            configFile = rdtWriteConfiguration(configuration, projectName, folder);
            
            % expected file
            [configPath, configBase, configExt] = fileparts(configFile);
            testCase.assertEqual(configPath, folder(1:end-1));
            testCase.assertEqual(configBase, 'rdt-config-this-is-a-test');
            testCase.assertEqual(configExt, '.json');
            
            % expected content
            writtenConfig = rdtConfiguration(configFile);
            testCase.sanityCheckConfiguration(writtenConfig);
            testCase.assertEqual(writtenConfig.serverUrl, configuration.serverUrl);
        end
    end
    
    methods (Access=private)
        function sanityCheckConfiguration(testCase, configuration)
            testCase.assertNotEmpty(configuration);
            testCase.assertInstanceOf(configuration, 'struct');
            testCase.assertThat(configuration, matlab.unittest.constraints.HasField('serverUrl'));
            testCase.assertThat(configuration, matlab.unittest.constraints.HasField('repositoryUrl'));
            testCase.assertThat(configuration, matlab.unittest.constraints.HasField('repositoryName'));
        end
    end
end
