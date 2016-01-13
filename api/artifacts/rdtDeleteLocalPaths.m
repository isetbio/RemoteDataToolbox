function [deleted, notDeleted] = rdtDeleteLocalPaths(configuration, remotePath)
%% Delete paths containing artifacts from the local artifact cache.
%
% [deleted, notDeleted] = rdtDeleteLocalPaths(configuration, remotePath)
% deletes one or more directories from the local artifact cache,
% corresponding to the given remotePath. configuration.cacheFolder should
% point to the root of the local artifact cache.  If
% configuration.cacheFolder is empty, the Gradle  default is used
% ('~/.gradle').
%
% The given remotePath should be a string artifact path, like those
% returned from rdtListRemotePaths().  remotePath may be a partial or
% "super" path, which matches multiple subpaths.
%
% This function has no effect on a remote server.
%
% Returns a cell array that contains the matching paths that were actually
% deleted. Also returns a cell array indicating matching paths that were
% not deleted, if any.
%
% See also rdtListLocalArtifacts rdtDeleteLocalArtifacts
%
% [deleted, notDeleted] = rdtDeleteLocalPaths(configuration, remotePath)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('configuration');
parser.addRequired('remotePath', @ischar);
parser.parse(configuration, remotePath);
configuration = rdtConfiguration(parser.Results.configuration);
remotePath = parser.Results.remotePath;

%% Delete all matching paths in the cache.
[localPaths, fullPaths] = rdtListLocalPaths(configuration, ...
    'remotePath', remotePath);

nPaths = numel(fullPaths);
isDeleted = false(1, nPaths);
for ii = 1:nPaths
    [isDeleted(ii), message] = rmdir(fullPaths{ii}, 's');
    if ~isDeleted(ii)
        fprintf('Could not delete path <%s>:\n%s\n', fullPaths{ii}, message);
    end
end

deleted = localPaths(isDeleted);
notDeleted = localPaths(~isDeleted);
