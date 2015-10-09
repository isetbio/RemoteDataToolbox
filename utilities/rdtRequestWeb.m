%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Make an http request to a web server.
%   @param resourcePath request path to append to the server url
%   @param queryParams struct of query params to add to the request path
%   @param requestBody string or struct for 'post' request body
%   @param configuration optional RemoteDataToolbox configuration struct
%
% @details
% Performs an http request to a web server.  If @a configuration is
% provided, sends the request to the server at @a configuration.serverUrl.
% Otherwise, uses the configuration returned from rdtConfiguration().
%
% @details
% Appends the given @a resourcePath to @a configuration serverUrl to form a
% complete resource URL.  If @a queryParams is provided, it must be a
% struct with string field values.  Fields and values are included in the
% request as query parameters.
%
% @details
% By default, performs an http GET request.  If @a request body is
% provided, performs an http POST request including @a requestBody as the
% body.  If @a requestBody is a string, it is included verbatim.
% If @a requestBody is a struct, it is coverted to a string and included.
%
% @details
% The value of @a configuration.requestMediaType determines how a @a
% requestBody struct may be converted to string:
%   - 'application/json': converted to JSON string (default)
%   - so far that's the only option!
%   .
%
% @details
% Returns a string or struct representing the server's response to the http
% request.  If the request failed, returns ''.  By default returns the
% response body verbatim as a string.  The value of @a
% configuration.responseMediaType determines whether and how the reponse
% should be converted to a struct:
%   - 'application/json': treated as JSON string (default)
%   - so far that's the only option!
%   .
%
% @details
% Usage:
%   response = rdtRequestWeb(resourcePath, queryParams, requestBody, configuration)
%
% @ingroup utilities
function response = rdtRequestWeb(resourcePath, queryParams, requestBody, configuration)

response = '';

if nargin < 1 || isempty(resourcePath)
    resourcePath = '';
end

if nargin < 2 || isempty(queryParams)
    queryParams = struct();
end

if nargin < 3 || isempty(requestBody)
    requestBody = '';
end

if nargin < 4 || isempty(configuration)
    configuration = rdtConfiguration();
else
    configuration = rdtConfiguration(configuration);
end

%% Build the request URL.
serverUrl = configuration.serverUrl;
if '/' == serverUrl(end)
    serverUrl = serverUrl(1:end-1);
end

if '/' == resourcePath(1)
    resourcePath = resourcePath(2:end);
end

requestUrl = [serverUrl '/' resourcePath];

%% Parse query params.
queryNames = fieldnames(queryParams);
queryValues = struct2cell(queryParams);
nQueryParams = numel(queryNames);
queryPairs = cell(1, 2*nQueryParams);
queryPairs(1:2:end) = queryNames;
queryPairs(2:2:end) = queryValues;

%% Set up Matlab web request options.
options = weboptions( ...
    'UserName', configuration.username, ...
    'Password', configuration.password, ...
    'ContentType', 'text', ...
    'KeyName', 'Accept', ...
    'KeyValue', configuration.acceptMediaType);

%% Perform GET or POST?
if isempty(requestBody)
    responseText = webread(requestUrl, queryPairs{:}, options);
else
    if isstruct(requestBody)
        switch configuration.requestMediaType
            case 'application/json'
                requestBody = rdtToJson(requestBody);
        end
    end
    options.MediaType = configuration.requestMediaType;
    responseText = webwrite(requestUrl, requestBody, options);
end

if isempty(responseText)
    return;
end

%% Convert response to struct?
switch configuration.acceptMediaType
    case 'application/json'
        response = rdtFromJson(responseText);
    otherwise
        response = responseText;
end

