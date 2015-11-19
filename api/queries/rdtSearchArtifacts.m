function artifacts = rdtSearchArtifacts(configuration, searchText, varargin)
%% Search an Archiva Maven repository with fuzzy matching of free text.
%
% artifacts = rdtSearchArtifacts(configuration, searchText) searches an
% Archiva Maven repository for artifacts matching the given searchText.
% configuration.serverUrl must point to the Archiva server root.
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
parser.parse(configuration, searchText, varargin{:});
configuration = rdtConfiguration(parser.Results.configuration);
searchText = parser.Results.searchText;
remotePath = parser.Results.remotePath;
artifactId = parser.Results.artifactId;
version = parser.Results.version;
type = parser.Results.type;

artifacts = [];

%% Query the Archiva server with fuzzy matching on searchText.
resourcePath = '/restServices/archivaServices/searchService/quickSearch';
query.queryString = searchText;
response = rdtRequestWeb(configuration, resourcePath, 'queryParams', query);
if isempty(response)
    return;
end

nArtifacts = numel(response);
artifactCell = cell(1, nArtifacts);
for ii = 1:nArtifacts
    r =response{ii};
    r.remotePath = r.groupId;
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
