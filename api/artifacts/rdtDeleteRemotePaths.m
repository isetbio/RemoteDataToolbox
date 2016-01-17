function [deleted, notDeleted] = rdtDeleteRemotePaths(configuration, remotePath)
%% Delete paths containing artifacts from a remote server and the local cache.
%
%   [deleted, notDeleted] = rdtDeleteRemotePaths(configuration, remotePath)
% 
% Deletes one or more paths containing artifacts from a remote server and
% also from the local artifact cache. Thus, the local cache will not return
% the artifacts after this delete is executed on the remote server.
%
% Inputs:
% remotePath - string to the remote path.  
%   Should be a string artifact path, like those returned from
%   rdtListRemotePaths(). The remotePath may be a partial or "super" path,
%   which matches multiple subpaths.
% configuration.repositoryUrl - must point to the repository root.  
% configuration.cacheFolder   - should point to the root of the local
%   artifact cache.  If configuration.cacheFolder is empty, the Gradle
%   default is used ('~/.gradle'). 
%
% Returns:
%  deleted    - a cell array that contains the matching paths that were
%               actually deleted. 
%  notDeleted - a cell array indicating matching paths that were not
%               deleted, if any. 
%
% See also rdtDeleteArtifacts rdtDeleteLocalpaths
%
% Examples:
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('configuration');
parser.addRequired('remotePath', @ischar);
parser.parse(configuration, remotePath);
configuration = rdtConfiguration(parser.Results.configuration);
remotePath = parser.Results.remotePath;

%% Implementation note:
%
% This delete operation is implemented in an Archiva-specific way.  So from
% an implementation point of view, I would like to put this function in the
% api/queries folder along with other functions that use the Archiva
% RESTful API.
%
% But from a user point of view, it seems right to put this function here
% in api/artifacts along with other functions related to the artifact
% lifecycle.

%% Make an explicit list of sub-paths that will be deleted.
allPaths = rdtListRemotePaths(configuration);
filterMe = struct('remotePath', allPaths);
[~, matchingPaths] = rdtFilterStructArray(filterMe, 'remotePath', remotePath);
remotePaths = {matchingPaths.remotePath};

%% Remotely delete each sub-path one at a time.
nPaths = numel(remotePaths);
isDeleted = false(1, nPaths);
for ii = 1:nPaths
    % try to delete remotely
    isDeleted(ii) = archivaDeleteRemotePath(configuration, remotePaths{ii});
end

deleted = remotePaths(isDeleted);
notDeleted = remotePaths(~isDeleted);

%% Clean up the local cache.
rdtDeleteLocalPaths(configuration, remotePath);

% Ask Archiva to delete a remote path.
function isDeleted = archivaDeleteRemotePath(configuration, remotePath)
configuration.acceptMediaType = 'text/plain';
resourcePath = '/restServices/archivaServices/repositoriesService/deleteGroupId';
groupId = rdtPathSlashesToDots(remotePath);
deleteParams = struct( ...
    'repositoryId', configuration.repositoryName, ...
    'groupId', groupId);

try
    message = rdtRequestWeb(configuration, resourcePath, 'queryParams', deleteParams);
    isDeleted = strcmpi('true', message);
catch ex
    isDeleted = false;
    message = ex.message;
end

if ~isDeleted
    fprintf('Could not delete remote path <%s>:\n%s\n', remotePath, message);
    fprintf('Does your configuration have good credentials?\n');
end
