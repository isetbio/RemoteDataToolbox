classdef RdtRequestWebTests < matlab.unittest.TestCase
    % Test that we can make Web requests.
    % These tests rely on a handy RESTful test server that lets us perform
    % requests and sends us predictable responses:
    %   http://jsonplaceholder.typicode.com/
    
    properties (Access = private)
        testConfig = rdtConfiguration( ...
            'serverUrl', 'http://jsonplaceholder.typicode.com/', ...
            'username', '', ...
            'password', '', ...
            'requestMediaType', 'application/json', ...
            'acceptMediaType', 'application/json');
    end
    
    methods (Test)
        
        function testSimpleGet(testCase)
            response = rdtRequestWeb(testCase.testConfig, '/posts/1');
            testCase.assertNotEmpty(response);
            testCase.assertInstanceOf(response, 'struct');
            testCase.assertThat(response, matlab.unittest.constraints.HasField('id'));
            testCase.assertEqual(response.id, 1);
        end
        
        function testQueryGet(testCase)
            query.postId = 1;
            response = rdtRequestWeb(testCase.testConfig, '/comments', 'queryParams', query);
            testCase.assertNotEmpty(response);
            testCase.assertInstanceOf(response, 'cell');
            testCase.assertSize(response, [1, 5]);
            
            firstElement = response{1};
            testCase.assertInstanceOf(firstElement, 'struct');
            testCase.assertThat(firstElement, matlab.unittest.constraints.HasField('postId'));
            testCase.assertEqual(firstElement.postId, 1);
        end
        
        function testPost(testCase)
            postData.foo = 'bar';
            response = rdtRequestWeb(testCase.testConfig, '/posts', 'requestBody', postData);
            testCase.assertNotEmpty(response);
            testCase.assertInstanceOf(response, 'struct');
            testCase.assertThat(response, matlab.unittest.constraints.HasField('foo'));
            testCase.assertEqual(response.foo, 'bar');
        end
        
    end
end
