classdef RdtConfigurationTests < matlab.unittest.TestCase
    
    methods (Test)
        
        function testDeault(testCase)
            testCase.sanityCheckConfiguration(rdtConfiguration());
        end
        
        function testFromConfigFolder(testCase)
            testFolder = fileparts(mfilename('fullpath'));
            alternateConfigFolder = fullfile(testFolder, 'alternate-json-configuration');
            configuration = rdtConfiguration(alternateConfigFolder);
            testCase.assertEqual('alternate-repository-name', configuration.repositoryName);
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
    end
    
    methods (Access=private)
        function sanityCheckConfiguration(testCase, configuration)
            testCase.assertNotEmpty(configuration);
            testCase.assertInstanceOf(configuration, 'struct');
            testCase.assertThat(configuration, matlab.unittest.constraints.HasField('serverUrl'));
            testCase.assertThat(configuration, matlab.unittest.constraints.HasField('repositoryName'));
        end
    end
end
