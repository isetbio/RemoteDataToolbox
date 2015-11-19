function response = rdtRequestWeb(configuration, resourcePath, varargin)
%% Make an HTTP request to a Web server.
%
% response = rdtRequestWeb(configuration, resourcePath) performs an HTTP
% GET request to the server at configuration.serverUrl with the given
% resourcePath.
%
% For example, if configuration.serverUrl is "https://en.wikipedia.org" and
% resourcePath is "wiki/World_Wide_Web", GETs the content at
% "https://en.wikipedia.org/wiki/World_Wide_Web".
%
% response = rdtRequestWeb( ... 'queryParams', params) takes a params
% struct and adds the fields and values of params to the GET request as
% query parameters.
%
% response = rdtRequestWeb( ... 'requesteBody', body) performs a POST
% request instead of a GET request.  The given body is added to the request
% as the request body.
%
% The value of configuration.requestMediaType determines how a request body
% is treated:
%   - 'application/json': body may be a struct or array and is
%   automatically converted to JSON string
%   - otherwise: body must be a string and is added to the request as-is
%
% The value of configuration.acceptMediaType determines how the response is
% treated:
%   - 'application/json': response is treated as a JSON string and
%   automatically converted to a struct or array
%   - otherwise: response is treated as a string and returned as-is
%
% Returns the server response as a string, struct, or array, or the empty
% '' if the request failed.
%
% See also rdtFromJson rdtToJson
%
% response = rdtRequestWeb(configuration, resourcePath, varargin)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('configuration');
parser.addRequired('resourcePath', @ischar);
parser.addParameter('queryParams', struct(), @isstruct);
parser.addParameter('requestBody', '');
parser.parse(configuration, resourcePath, varargin{:});
configuration = rdtConfiguration(parser.Results.configuration);
resourcePath = parser.Results.resourcePath;
queryParams = parser.Results.queryParams;
requestBody = parser.Results.requestBody;

response = '';

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

