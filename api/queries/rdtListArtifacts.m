function artifacts = rdtListArtifacts(configuration, remotePath)
%% Query an Archiva Maven repository for artifacts under a remote path.
%
% artifacts = rdtListArtifacts(configuration, remotePath) requests a list
% of all artifacts under the given remotePath, from an
% Archiva Maven repository.  configuration.serverUrl must point to the
% Archiva server root.  configuration.repositoryName must contain the
% name of a repository on the server.
%
% artifacts = rdtListArtifacts( ... 'pageSize', pageSize) restricts
% the number of search results to the given pageSize.  The default is 1000.
%
% Returns a struct array describing artifacts under the given
% remotePath, or else [] if the query failed.
%
% See also rdtListRemotePaths, rdtSearchArtifacts, rdtArtifact
%
% artifacts = rdtListArtifacts(configuration, remotePath)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('configuration');
parser.addRequired('remotePath', @ischar);
parser.addParameter('pageSize', 1000);
parser.parse(configuration, remotePath);
configuration = rdtConfiguration(parser.Results.configuration);
remotePath = parser.Results.remotePath;
pageSize = parser.Results.pageSize;

artifacts = [];

%% Query the Archiva server.
resourcePath = '/restServices/archivaServices/searchService/searchArtifacts';

% hack: repeat repositoryName forces JSON array, not scalar string
searchRequest.repositories = {configuration.repositoryName, configuration.repositoryName};
searchRequest.groupId = rdtPathSlashesToDots(remotePath);
searchRequest.pageSize = pageSize;

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
