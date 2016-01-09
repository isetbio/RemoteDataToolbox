function artifacts = rdtListLocalArtifacts(configuration, remotePath, varargin)
%% Query locally cached artifacts under the given remotePath.
%
% artifacts = rdtListLocalArtifacts(configuration, remotePath) builds a
% list of all locally cached artifacts originating from the given
% remotePath. configuration.cacheFolder should point to the root of the
% local artifact cache.  If configuration.cacheFolder is empty, the Gradle
% default is used ('~/.gradle').
%
% artifacts = rdtListLocalArtifacts( ... 'artifactId', artifactId)
% restricts search results to artifacts with exactly the given artifactId.
%
% artifacts = rdtListLocalArtifacts( ... 'version', version) restricts
% search results to artifacts with exactly the given version.
%
% artifacts = rdtListLocalArtifacts( ... 'type', type) restricts
% search results to artifacts with exactly the given type.
%
% Returns a struct array describing locally cached artifacts under the
% given remotePath, or else [] if there are none.
%
% See also rdtListArtifacts, rdtSearchArtifacts, rdtArtifact
%
% artifacts = rdtListLocalArtifacts(configuration, remotePath, varargin)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('configuration');
parser.addRequired('remotePath',  @(p)ischar(p) && ~isempty(p));
parser.addParameter('artifactId', '', @ischar);
parser.addParameter('version', '', @ischar);
parser.addParameter('type', '', @ischar);
parser.parse(configuration, remotePath, varargin{:});
configuration = rdtConfiguration(parser.Results.configuration);
remotePath = parser.Results.remotePath;
artifactId = parser.Results.artifactId;
version = parser.Results.version;
type = parser.Results.type;

artifacts = [];

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
    warning('rdtListLocalArtifacts:cacheFolderMissing', ...
        'No cache folder exists at <%s>.', cacheFolder);
    return;
end

%% Locate the remotePaths at or below this group.
superGroupId = rdtPathSlashesToDots(remotePath);
cacheDirectories = dir(cachePath);
[~, groupDirectories] = rdtFilterStructArray(cacheDirectories, ...
    'name', superGroupId, ...
    'matchStyle', 'prefix');

if isempty(groupDirectories)
    warning('rdtListLocalArtifacts:remotePathMissing', ...
        'No cache entries for remotePath <%s>.', remotePath);
    return;
end

%% Locate artifacts, versions, and files in each group.
% it's deep, but constant depth, so let's do it!
artifactCell = {};
for gg = 1:numel(groupDirectories)
    groupId = groupDirectories(gg).name;
    artifactRemotePath = rdtPathDotsToSlashes(groupId);
    groupPath = fullfile(cachePath, groupId);
    artifactDirectories = getMatchingEntries(dir(groupPath), artifactId);
    for aa = 1:numel(artifactDirectories)
        localArtifactId = artifactDirectories(aa).name;
        artifactPath = fullfile(groupPath, localArtifactId);
        versionDirectories = getMatchingEntries(dir(artifactPath), version);
        for vv = 1:numel(versionDirectories)
            localVersion = versionDirectories(vv).name;
            versionPath = fullfile(artifactPath, localVersion);
            checksumDirectories = getMatchingEntries(dir(versionPath), '');
            for cc = 1:numel(checksumDirectories)
                checksum = checksumDirectories(cc).name;
                checksumPath = fullfile(versionPath, checksum);
                fileEntries = getMatchingEntries(dir(checksumPath), '');
                for ff = 1:numel(fileEntries)
                    fileName = fileEntries(ff).name;
                    filePath = fullfile(checksumPath, fileName);
                    [~, ~, fileExt] = fileparts(filePath);
                    localType = fileExt(2:end);
                    if isempty(type) || strcmp(type, localType)
                        % don't know how many artifacts to preallocate
                        %   we long for a containers.List...alas
                        artifactCell{end+1} = rdtArtifact( ...
                            'artifactId', localArtifactId, ...
                            'localPath', filePath, ...
                            'remotePath', artifactRemotePath, ...
                            'type', fileExt(2:end), ...
                            'version', localVersion);
                    end
                end
            end
        end
    end
end
artifacts = [artifactCell{:}];

%% Filter out non-matching entries, and always remove "." and "..".
function dirs = getMatchingEntries(dirs, name)
% we don't like the meta-entries "." and ".."!
isMeta = rdtFilterStructArray(dirs, 'name', '.') | rdtFilterStructArray(dirs, 'name', '..');
dirs = dirs(~isMeta);

% match on name, or pass if given name is empty
[~, dirs] = rdtFilterStructArray(dirs, 'name', name);
