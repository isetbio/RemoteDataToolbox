%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Query an Archiva Maven repository to list all artifact groups
%   @param configuration optional RemoteDataToolbox configuration struct
%
% @details
% Requests a list of all artifact groups from an Archiva Maven repository.
% If @a configuration is provided, queries the server at @a
% configuration.repository.  Otherwise, uses the configuration returned
% from rdtConfiguration().
%
% @details
% Returns a cell array string groupIds returned from the Archiva
% respository, or {} if the query failed.
%
% @details
% Usage:
%   groupIds = rdtListGroups(configuration)
%
% @ingroup queries
function groupIds = rdtListGroups(configuration)

groupIds = {};

if nargin < 1 || isempty(configuration)
    configuration = rdtConfiguration();
else
    configuration = rdtConfiguration(configuration);
end

%% Query the Archiva server.
resourcePath = '/restServices/archivaServices/searchService/getAllGroupIds';
params.selectedRepos = configuration.repositoryName;
response = rdtRequestWeb(resourcePath, params, [], configuration);
if isempty(response) || ~isfield(response, 'groupIds')
    return;
end
groupIds = response.groupIds;
