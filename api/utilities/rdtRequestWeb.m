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

% History:
%  10/19/20  dhb  Add 'CertificateFilename','' to list of key/value pairs
%                 for webread/webwrite options.  This fixes an SSL cert
%                 error in more recent versions of Matlab.

parser = rdtInputParser();
parser.addRequired('configuration');
parser.addRequired('resourcePath', @ischar);
parser.addParameter('queryParams', struct(), @isstruct);
parser.addParameter('requestBody', '');
parser.addParameter('forceFallback', false, @islogical);
parser.parse(configuration, resourcePath, varargin{:});
configuration = rdtConfiguration(parser.Results.configuration);
resourcePath = parser.Results.resourcePath;
queryParams = parser.Results.queryParams;
requestBody = parser.Results.requestBody;
forceFallback = parser.Results.forceFallback;

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

%% Parse query params if any.
queryNames = fieldnames(queryParams);
queryValues = struct2cell(queryParams);
nQueryParams = numel(queryNames);
queryPairs = cell(1, 2*nQueryParams);
queryPairs(1:2:end) = queryNames;
queryPairs(2:2:end) = queryValues;

%% Encode request body if any.
if ~isempty(requestBody) && isstruct(requestBody)
    switch configuration.requestMediaType
        case 'application/json'
            requestBody = rdtToJson(requestBody);
    end
end

if forceFallback || verLessThan('matlab', '8.6')
    %% Fall back on third-party RESTful utility.
    headers = encodeHeaders(configuration);
    
    % GET or POST?
    if isempty(requestBody)
        encodedUrl = encodeQueryUrl(requestUrl, queryPairs);
        responseText = urlread2(encodedUrl, 'GET', '', headers, ...
            'CAST_OUTPUT', true);
    else
        responseText = urlread2(requestUrl, 'POST', requestBody, headers, ...
            'CAST_OUTPUT', true);
    end
    
else
    %% Use official RESTful utility
    options = weboptions( ...
        'UserName', configuration.username, ...
        'Password', configuration.password, ...
        'ContentType', 'text', ...
        'KeyName', 'Accept', ...
        'KeyValue', configuration.acceptMediaType, ...
        'CertificateFilename','');
    
    % GET or POST?
    if isempty(requestBody)
        responseText = webread(requestUrl, queryPairs{:}, options);
    else
        options.MediaType = configuration.requestMediaType;
        responseText = webwrite(requestUrl, requestBody, options);
    end
    
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

%% Encode HTTP headers from toolbox config.
function headers = encodeHeaders(configuration)

headers = [];

userAgent = sprintf('Remote Data Toolbox, Matlab %s', version);
headers = [headers, http_createHeader('User-Agent', userAgent)];

if ~isempty(configuration.requestMediaType)
    contentType = configuration.requestMediaType;
    headers = [headers, http_createHeader('Content-Type', contentType)];
end

if ~isempty(configuration.acceptMediaType)
    acceptType = configuration.acceptMediaType;
    headers = [headers, http_createHeader('Accept', acceptType)];
end

if ~isempty(configuration.username) || ~isempty(configuration.password)
    % Basic Auth is a standard not likely to change.
    %   stole: MATLAB/R2015b/toolbox/matlab/iofun/private/urlreadwrite.m
    import org.apache.commons.codec.binary.Base64;
    usernamePassword = [configuration.username ':' configuration.password];
    usernamePasswordBytes = int8(usernamePassword)';
    usernamePasswordBase64 = char(Base64.encodeBase64(usernamePasswordBytes)');
    basicAuth = ['Basic ' usernamePasswordBase64];
    
    headers = [headers, http_createHeader('Authorization', basicAuth)];
end

%% Url-encode query params and append to a url.
function queryUrl = encodeQueryUrl(requestUrl, queryPairs)

if isempty(queryPairs)
    queryUrl = requestUrl;
    return;
end

nParams = numel(queryPairs) / 2;
queryCell = cell(4, nParams);
queryCell{1,1} = '?';
[queryCell{1,2:end}] = deal('&');
[queryCell{3,1:end}] = deal('=');
for ii = 1:nParams
    name = queryPairs{2 * ii - 1};
    value = queryPairs{2 * ii};
    if ~ischar(value)
        value = num2str(value);
    end
    queryCell{2,ii} = urlencode(name);
    queryCell{4,ii} = urlencode(value);
end

queryUrl = [requestUrl queryCell{:}];
