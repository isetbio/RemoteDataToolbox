function [localPaths, fullPaths] = rdtListLocalPaths(configuration, varargin)
%% Query locally cached artifact paths.
%
% artifacts = rdtListLocalPaths(configuration) builds a list of paths
% containing locally cached artifacts.  configuration.cacheFolder should
% point to the root of the local artifact cache.  If
% configuration.cacheFolder is empty, the Gradle default is used
% ('~/.gradle').
%
% rdtListLocalPaths(... 'remotePath', remotePath) restricts the results to
% local paths that correspond to the given remotePath.  remotePath may be a
% partial or "super" path, which matches multiple subpaths.
%
% rdtListLocalPaths(... 'sortFlag', sortFlag) determines whether the
% list of paths will be sorted.  The default is true, sorted.
%
% Returns a cell array of string paths found in the local cache, or {} if
% the search failed.  These are formatted like artifact remotePaths.  Also
% returns a cell array of full, absolute paths into the local artifact
% cache.  These are formatted as full paths.
%
% See also rdtListRemotePaths, rdtListLocalArtifacts
%
% [localPaths, groupDirectories] = rdtListLocalPaths(configuration, varargin)
%
% Copyright (c) 2016 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('configuration');
parser.addParameter('remotePath', '', @ischar);
parser.addParameter('sortFlag', true, @islogical);
parser.parse(configuration, varargin{:});
configuration = rdtConfiguration(parser.Results.configuration);
remotePath = parser.Results.remotePath;
sortFlag = parser.Results.sortFlag;

localPaths = {};
fullPaths = {};

%% Implementaiton note.
% The Gradle cache is nicely organized but slightly fussy to traverse.
% Here is an example entry from isetbio:
%   (cachePath)/validation.fast.outersegment/osBioPhysObject/run00001/4128b5adc8d39b7c42fa2eb9c5fa147c7aa38ca8/osBioPhysObject-run00001.pom
% We can interpret this as:
%   (cachePath)/groupId/artifactId/version/(checksum)/(file-name).type
% Note that the groupId is a flattened version of the remotePath.  So
%   (cachePath)/validation.fast.outersegment
% and
%   (cachePath)/validation.fast.colors
% are *peers at the root level*.  They are not siblings nested under their
% common super-group, which would be "validation.fast".  Flat groupIds are
% great, because the keep the cache file tree at constant depth and we
% don't have to do recursive traversal to arbitrary depths.  But, when we
% want to collect a whole super-group like "validation.fast" we have to
% find all the flattened groups by prefix matching.

%% Locate the local artifact cache.
cacheFolder = configuration.cacheFolder;
if isempty(cacheFolder)
    cacheFolder = '~/.gradle';
end

% magic subfolder used by Gradle, which we expect not to change
GRADLE_CACHES_SUBFOLDER = '/caches/modules-2/files-2.1';
cachePath = fullfile(cacheFolder, GRADLE_CACHES_SUBFOLDER);

if 7 ~= exist(cachePath, 'dir')
    warning('rdtListLocalPaths:cacheFolderMissing', ...
        'No cache folder exists at <%s>.', cacheFolder);
    return;
end

%% Locate the remotePaths at or below the given remotePath.
superGroupId = rdtPathSlashesToDots(remotePath);
cacheDirectories = dir(cachePath);
[~, groupDirectories] = rdtFilterStructArray(cacheDirectories, ...
    'name', superGroupId, ...
    'matchStyle', 'prefix');

if isempty(groupDirectories)
    warning('rdtListLocalPaths:remotePathMissing', ...
        'No cache entries for remotePath <%s>.', remotePath);
    return;
end

%% Pack up the results.
% convert group names with dots to paths with slashes
nGroups = numel(groupDirectories);
localPaths = cell(1, nGroups);
fullPaths = cell(1, nGroups);
for gg = 1:nGroups
    groupId = groupDirectories(gg).name;
    localPaths{gg} = rdtPathDotsToSlashes(groupId);
    fullPaths{gg} = fullfile(cachePath, groupId);
end

% optional sort
if sortFlag
    [localPaths, order] = sort(localPaths);
    fullPaths = fullPaths(order);
end
