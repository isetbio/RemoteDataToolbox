function [remotePaths, repositoryName] = rdtListRemotePaths(configuration)
%% Query an Archiva Maven repository to list available paths to artifacts.
%
% [remotePaths, repositoryName] = rdtListRemotePaths(configuration)
% requests a list of paths to artifacts on an Archiva Maven repository.
% configuration.serverUrl must point to the Archiva server root.
% configuration.repositoryName must contain the name of a repository on the
% server.
%
% Returns a cell array string paths returned from the Archiva respository,
% or {} if the query failed.  Also returns the name of the repository whose
% paths are listed.
%
% See also rdtListArtifacts, rdtSearchArtifacts
%
% [remotePaths, repositoryName] = rdtListRemotePaths(configuration)
%
% Copyright (c) 2015 RemoteDataToolbox Team

configuration = rdtConfiguration(configuration);

remotePaths = {};

%% Query the Archiva server.
resourcePath = '/restServices/archivaServices/searchService/getAllGroupIds';
repositoryName = configuration.repositoryName;
params.selectedRepos = repositoryName;
response = rdtRequestWeb(configuration, resourcePath, 'queryParams', params);
if isempty(response) || ~isfield(response, 'groupIds')
    return;
end
remotePaths = response.groupIds;
