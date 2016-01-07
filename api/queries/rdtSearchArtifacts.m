function artifacts = rdtSearchArtifacts(configuration, searchText, varargin)
%% Search an Archiva Maven repository with fuzzy matching of free text.
%
% artifacts = rdtSearchArtifacts(configuration, searchText) searches an
% Archiva Maven repository for artifacts matching the given searchText.
% configuration.serverUrl must point to the Archiva server root.
%
% By default the server restricts the number of search results to 30.  To
% get more results at once, use rdtListArtifacts() with a large value for
% the the 'pageSize' parameter.
%
% artifacts = rdtSearchArtifacts( ... 'remotePath', remotePath) restricts
% search results to artifacts with exactly the given remotePath.
%
% artifacts = rdtSearchArtifacts( ... 'artifactId', artifactId) restricts
% search results to artifacts with exactly the given artifactId.
%
% artifacts = rdtSearchArtifacts( ... 'version', version) restricts
% search results to artifacts with exactly the given version.
%
% artifacts = rdtSearchArtifacts( ... 'type', type) restricts
% search results to artifacts with exactly the given type.
%
% artifacts = rdtSearchArtifacts( ... 'pageSize', pageSize) restricts
% the number of search results to the given pageSize.  The default is 1000.
%
% Returns a struct array describing artifacts that matched the given
% searchText and other restrictions, or else [] if the query failed.
%
% See also rdtListRemotePaths, rdtListArtifacts, rdtArtifact
%
% artifacts = rdtSearchArtifacts(configuration, searchText, varargin)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('configuration');
parser.addRequired('searchText', @ischar);
parser.addParameter('remotePath', '', @ischar);
parser.addParameter('artifactId', '', @ischar);
parser.addParameter('version', '', @ischar);
parser.addParameter('type', '', @ischar);
parser.addParameter('pageSize', 1000);
parser.parse(configuration, searchText, varargin{:});
configuration = rdtConfiguration(parser.Results.configuration);
searchText = parser.Results.searchText;
remotePath = parser.Results.remotePath;
artifactId = parser.Results.artifactId;
version = parser.Results.version;
type = parser.Results.type;
pageSize = parser.Results.pageSize;

artifacts = [];

%% Query the Archiva server with fuzzy matching on searchText.
resourcePath = '/restServices/archivaServices/searchService/quickSearchWithRepositories';

% hack: repeat repositoryName forces JSON array, not scalar string
searchRequest.repositories = {configuration.repositoryName, configuration.repositoryName};
searchRequest.queryTerms = searchText;
searchRequest.pageSize = pageSize;
searchRequest.selectedPage = 0;

response = rdtRequestWeb(configuration, resourcePath, 'requestBody', searchRequest);
if isempty(response)
    return;
end

nArtifacts = numel(response);
artifactCell = cell(1, nArtifacts);
for ii = 1:nArtifacts
    r = response{ii};
    r.remotePath = rdtPathDotsToSlashes(r.groupId);
    artifactCell{ii} = rdtArtifact(r);
end
artifacts = [artifactCell{:}];

%% Filter results for given restrictions.
% Would prefer to let the server do the filtering as part of the query,
% instead of transferring extra results and doing filtering here on the
% client side.  But in testing, the Archiva searchArtifacts resource didn't
% allow this.
isMatch = isFieldMatch(artifacts, 'remotePath', remotePath) ...
    & isFieldMatch(artifacts, 'artifactId', artifactId) ...
    & isFieldMatch(artifacts, 'version', version) ...
    & isFieldMatch(artifacts, 'type', type);
artifacts = artifacts(isMatch);

%% True where each element has given field equal to given string.
function isMatch = isFieldMatch(structArray, fieldName, fieldString)
nElements = numel(structArray);
isMatch = true(1, nElements);

% default "all elements match"
if isempty(fieldString)
    return;
end

% check each element explicitly
for ii = 1:nElements
    isMatch(ii) = strcmp(fieldString, structArray(ii).(fieldName));
end
