%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Query an Archiva Maven repository to list all artifact in a group.
%   @param groupId string id of the group from which to list artifacts
%   @param configuration optional RemoteDataToolbox configuration struct
%
% @details
% Requests a list of all artifacts from the given groupId, from an Archiva
% Maven repository.  If @a configuration is provided, queries the server at
% @a configuration.repository.  Otherwise, uses the configuration returned
% from rdtConfiguration().
%
% @details
% Returns a struct array describing artifacts in the given @a groupId, or
% else [] if the query failed.
%
% @details
% Usage:
%   artifacts = rdtListArtifacts(groupId, configuration)
%
% @ingroup queries
function artifacts = rdtListArtifacts(groupId, configuration)

artifacts = [];

if nargin < 2 || isempty(configuration)
    configuration = rdtConfiguration();
else
    configuration = rdtConfiguration(configuration);
end

%% Query the Archiva server.
resourcePath = '/restServices/archivaServices/searchService/searchArtifacts';

% hack: repeat repositoryName forces JSON array, not scalar string
searchRequest.repositories = {configuration.repositoryName, configuration.repositoryName};
searchRequest.groupId = groupId;

response = rdtRequestWeb(resourcePath, [], searchRequest, configuration);
if isempty(response)
    return;
end

nArtifacts = numel(response);
artifactCell = cell(1, nArtifacts);
for ii = 1:nArtifacts
    artifactCell{ii} = rdtArtifact(response{ii});
end
artifacts = [artifactCell{:}];
