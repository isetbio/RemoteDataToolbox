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

%% Get the repository's root paths.
resourcePath = '/restServices/archivaServices/browseService/rootGroups';
params.repositoryId = repositoryName;
response = rdtRequestWeb(configuration, resourcePath, 'queryParams', params);
if isempty(response) || ~isfield(response, 'browseResultEntries')
    return;
end

rootRecords = [response.browseResultEntries{:}];
rootGroupIds = {rootRecords.name};

%% Recursively explore each root path.
allGroupIds = drillDownGroups(configuration, rootGroupIds);

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

% Recurseively "browse" groups for sub-groups.
function allGroupIds = drillDownGroups(configuration, groupIds)
baseResourcePath = '/restServices/archivaServices/browseService/browseGroupId';
params.repositoryId = configuration.repositoryName;

nGroups = numel(groupIds);
subGroupIds = cell(1, nGroups);
for gg = 1:nGroups
    groupId = groupIds{gg};
    
    % get the child groups of each given group
    resourcePath = [baseResourcePath '/' groupId];
    response = rdtRequestWeb(configuration, resourcePath, 'queryParams', params);
    if isempty(response) || ~isfield(response, 'browseResultEntries')
        continue;
    end
    
    % ignore artifact listings, we only want groups
    childRecords = [response.browseResultEntries{:}];
    if isempty(childRecords)
        continue;
    end
    isGroup = cellfun(@isempty, {childRecords.artifactId});
    childGroupIds = {childRecords(isGroup).name};
    
    % recursive: get all descendants of each given group
    subGroupIds{gg} = drillDownGroups(configuration, childGroupIds);
end

% combine all given groupIds and childGroupIds
allGroupIds = cat(2, groupIds, subGroupIds{:});
