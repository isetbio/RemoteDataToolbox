classdef RdtRequestWebTests < matlab.unittest.TestCase
    % Test that we can make Web requests.
    % These tests rely on handy RESTful test servers that lets us perform
    % requests and sends us predictable responses:
    %   http://jsonplaceholder.typicode.com/
    %   http://httpbin.org/basic-auth/
    
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
        
        function testSimpleGetFallback(testCase)
            response = rdtRequestWeb(testCase.testConfig, '/posts/1', ...
                'forceFallback', true);
            testCase.assertNotEmpty(response);
            testCase.assertInstanceOf(response, 'struct');
            testCase.assertThat(response, matlab.unittest.constraints.HasField('id'));
            testCase.assertEqual(response.id, 1);
        end
        
        function testQueryGet(testCase)
            query.postId = 1;
            response = rdtRequestWeb(testCase.testConfig, '/comments', ...
                'queryParams', query);
            testCase.assertNotEmpty(response);
            testCase.assertInstanceOf(response, 'cell');
            testCase.assertSize(response, [1, 5]);
            
            firstElement = response{1};
            testCase.assertInstanceOf(firstElement, 'struct');
            testCase.assertThat(firstElement, matlab.unittest.constraints.HasField('postId'));
            testCase.assertEqual(firstElement.postId, 1);
        end
        
        function testQueryGetFallback(testCase)
            query.postId = 1;
            response = rdtRequestWeb(testCase.testConfig, '/comments', ...
                'queryParams', query, ...
                'forceFallback', true);
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
            response = rdtRequestWeb(testCase.testConfig, '/posts', ...
                'requestBody', postData);
            testCase.assertNotEmpty(response);
            testCase.assertInstanceOf(response, 'struct');
            testCase.assertThat(response, matlab.unittest.constraints.HasField('foo'));
            testCase.assertEqual(response.foo, 'bar');
        end
        
        function testPostFallback(testCase)
            postData.foo = 'bar';
            response = rdtRequestWeb(testCase.testConfig, '/posts', ...
                'requestBody', postData, ...
                'forceFallback', true);
            testCase.assertNotEmpty(response);
            testCase.assertInstanceOf(response, 'struct');
            testCase.assertThat(response, matlab.unittest.constraints.HasField('foo'));
            testCase.assertEqual(response.foo, 'bar');
        end
        
        function testBasicAuth(testCase)
            % httpbin lets us make a request at
            %   /basic-auth/username/password
            % so we can make up credentials and test that they pass
            alphabet = 'a':'z';
            username = alphabet(randperm(numel(alphabet)));
            password = alphabet(randperm(numel(alphabet)));
            
            authConfig = rdtConfiguration( ...
                'serverUrl', 'http://httpbin.org/', ...
                'username', username, ...
                'password', password, ...
                'requestMediaType', 'application/json', ...
                'acceptMediaType', 'application/json');
            
            resourcePath = ['/basic-auth/' username '/' password];
            response = rdtRequestWeb(authConfig, resourcePath);
            testCase.assertNotEmpty(response);
            testCase.assertInstanceOf(response, 'struct');
            testCase.assertEqual(response.authenticated, 1);
            testCase.assertEqual(response.user, username);
        end
        
        function testBasicAuthFallback(testCase)
            % httpbin lets us make a request at
            %   /basic-auth/username/password
            % so we can make up credentials and test that they pass
            alphabet = 'a':'z';
            username = alphabet(randperm(numel(alphabet)));
            password = alphabet(randperm(numel(alphabet)));
            
            authConfig = rdtConfiguration( ...
                'serverUrl', 'http://httpbin.org/', ...
                'username', username, ...
                'password', password, ...
                'requestMediaType', 'application/json', ...
                'acceptMediaType', 'application/json');
            
            resourcePath = ['/basic-auth/' username '/' password];
            response = rdtRequestWeb(authConfig, resourcePath, ...
                'forceFallback', true);
            testCase.assertNotEmpty(response);
            testCase.assertInstanceOf(response, 'struct');
            testCase.assertEqual(response.authenticated, 1);
            testCase.assertEqual(response.user, username);
        end
        
    end
end
