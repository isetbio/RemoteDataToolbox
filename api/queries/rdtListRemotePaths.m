function [remotePaths, repositoryName] = rdtListRemotePaths(configuration, varargin)
%% Query an Archiva Maven repository to list available paths to artifacts.
%
% [remotePaths, repositoryName] = rdtListRemotePaths(configuration)
% requests a list of paths to artifacts on an Archiva Maven repository.
% configuration.serverUrl must point to the Archiva server root.
% configuration.repositoryName must contain the name of a repository on the
% server.
%
% rdtListRemotePaths(... 'sortFlag', sortFlag) determines whether the
% list of remote paths will be sorted.  The default is true, sorted.
%
% Returns a cell array of string paths returned from the Archiva
% respository, or {} if the query failed.  Also returns the name of the
% repository whose paths are listed.
%
% See also rdtListArtifacts, rdtSearchArtifacts
%
% [remotePaths, repositoryName] = rdtListRemotePaths(configuration)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('configuration');
parser.addParameter('sortFlag', true, @islogical);
parser.parse(configuration, varargin{:});
configuration = rdtConfiguration(parser.Results.configuration);
sortFlag = parser.Results.sortFlag;

remotePaths = {};
repositoryName = configuration.repositoryName;

%% Get all the artifacts.
resourcePath = ['/restServices/archivaServices/browseService/artifacts/' repositoryName ];
response = rdtRequestWeb(configuration, resourcePath);
if isempty(response)
    return;
end

%% Pare down to the unique group ids.
artifactRecords = [response{:}];
groupIds = {artifactRecords.groupId};
[~, order] = unique(groupIds);

% undo the sorting from unique(), so that sort remains optional below
allGroupIds = groupIds(sort(order));


%% Convert group names with dots to paths with slashes
nPaths = numel(allGroupIds);
remotePaths = cell(1, nPaths);
for gg = 1:nPaths
    remotePaths{gg} = rdtPathDotsToSlashes(allGroupIds{gg});
end

% optional sort
if sortFlag
    remotePaths = sort(remotePaths);
end
