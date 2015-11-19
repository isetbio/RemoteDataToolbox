function artifacts = rdtListArtifacts(configuration, remotePath)
%% Query an Archiva Maven repository for artifacts under a remote path.
%
% artifacts = rdtListArtifacts(configuration, remotePath) requests a list
% of all artifacts under the given @a remotePath, from an
% Archiva Maven repository.  @a configuration.serverUrl must point to the
% Archiva server root.  @a configuration.repositoryName must contain the
% name of a repository on the server.
%
% Returns a struct array describing artifacts under the given @a
% remotePath, or else [] if the query failed.
%
% See also rdtListRemotePaths, rdtSearchArtifacts, rdtArtifact
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('configuration');
parser.addRequired('remotePath', @ischar);
parser.parse(configuration, remotePath);
configuration = rdtConfiguration(parser.Results.configuration);
remotePath = parser.Results.remotePath;

artifacts = [];

%% Query the Archiva server.
resourcePath = '/restServices/archivaServices/searchService/searchArtifacts';

% hack: repeat repositoryName forces JSON array, not scalar string
searchRequest.repositories = {configuration.repositoryName, configuration.repositoryName};
searchRequest.groupId = remotePath;

response = rdtRequestWeb(configuration, resourcePath, 'requestBody', searchRequest);
if isempty(response)
    return;
end

nArtifacts = numel(response);
artifactCell = cell(1, nArtifacts);
for ii = 1:nArtifacts
    r = response{ii};
    r.remotePath = r.groupId;
    artifactCell{ii} = rdtArtifact(r);
end
artifacts = [artifactCell{:}];
