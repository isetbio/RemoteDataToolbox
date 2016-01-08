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
% search results to artifacts under the given remotePath.
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

hits = rdtRequestWeb(configuration, resourcePath, 'requestBody', searchRequest);
if isempty(hits)
    return;
end

%% Query to list files under each search hit.
%   We need to do this in case there are multiple files under a given
%   artifact -- the text seach above returns only one hit in that case.
nHits = numel(hits);
artifactCell = cell(1, nHits);
for ii = 1:nHits
    hit = hits{ii};
    
    % list artifacts under this search result
    artifactCell{ii} = rdtListArtifacts(configuration, ...
        rdtPathDotsToSlashes(hit.groupId), ...
        'artifactId', hit.artifactId, ...
        'version', hit.version, ...
        'pageSize', pageSize);
end
artifacts = [artifactCell{:}];

if isempty(artifacts)
    return;
end

%% Filter results for given restrictions.
% rdtListArtifacts() does use server-side filtering.  But here we are
% combining results from multiple searches, so we do the filtering on the
% client side.
isMatch = rdtFilterStructArray(artifacts, 'remotePath', remotePath, 'matchStyle', 'prefix') ...
    & rdtFilterStructArray(artifacts, 'artifactId', artifactId) ...
    & rdtFilterStructArray(artifacts, 'version', version) ...
    & rdtFilterStructArray(artifacts, 'type', type);
artifacts = artifacts(isMatch);
