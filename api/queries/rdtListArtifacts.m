%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Query an Archiva Maven repository for artifacts under a remote path.
%   @param configuration RemoteDataToolbox configuration info
%   @param remotePath string remote path under which to list artifacts
%
% @details
% Requests a list of all artifacts under the given @a remotePath, from an
% Archiva Maven repository.  @a configuration.serverUrl should point to the
% Archiva server root.  @a configuration.repositoryName shold contain the
% name of a on the same server.
%
% @details
% Returns a struct array describing artifacts under the given @a
% remotePath, or else [] if the query failed.
%
% @details
% Usage:
%   artifacts = rdtListArtifacts(configuration, remotePath)
%
% @ingroup queries
function artifacts = rdtListArtifacts(configuration, remotePath)

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
