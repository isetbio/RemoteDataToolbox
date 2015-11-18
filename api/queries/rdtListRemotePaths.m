%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Query an Archiva Maven repository to list available paths to artifacts.
%   @param configuration RemoteDataToolbox configuration info
%
% @details
% Requests a list of paths to artifacts on an Archiva Maven repository.
% @a configuration.serverUrl should point to the Archiva server root.
%
% @details
% Returns a cell array string paths returned from the Archiva
% respository, or {} if the query failed.  Also returns the name of the
% repository whose paths are listed.
%
% @details
% Usage:
%   [remotePaths, repositoryName] = rdtListRemotePaths(configuration)
%
% @ingroup queries
function [remotePaths, repositoryName] = rdtListRemotePaths(configuration)

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
