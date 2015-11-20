function artifact = rdtPublishArtifact(configuration, file, remotePath, varargin)
%% Publish an artifact to a remote repository.
%
% artifact = rdtPublishArtifact(configuration, file, remotePath) publishes
% the given file as an artifact to a remote respository, at the given
% remotePath.  configuration.repositoryUrl must point to the repository
% root.
%
% artifact = rdtPublishArtifact(... 'artifactId', artifactId) uses the
% given artifactId instead of the default file base name.
%
% artifact = rdtPublishArtifact(... 'version', version) uses the
% given version instead of the default '1'.
%
% Returns a struct of metadata about the published artifact, or [] if the
% publication failed.
%
% See also rdtArtifact rdtPublishArtifacts
%
% artifact = rdtPublishArtifact(configuration, file, remotePath, varargin)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('configuration');
parser.addRequired('file', @ischar);
parser.addRequired('remotePath', @ischar);
parser.addParameter('artifactId', '', @ischar);
parser.addParameter('version', '1', @ischar);
parser.parse(configuration, file, remotePath, varargin{:});
configuration = rdtConfiguration(parser.Results.configuration);
file = parser.Results.file;
remotePath = parser.Results.remotePath;
artifactId = parser.Results.artifactId;
version = parser.Results.version;

if isempty(artifactId)
    [~, artifactId] = fileparts(file);
end

artifact = [];

%% Publish the artifact.
[localPath, type] = gradlePublishArtifact(configuration.repositoryUrl, ...
    configuration.username, ...
    configuration.password, ...
    remotePath, ...
    artifactId, ...
    version, ...
    file, ...
    configuration.cacheFolder);

if isempty(localPath)
    return;
end

%% Build an artifact struct for the fetched artifact.
repoParts = rdtPathParts(configuration.repositoryUrl, 'separator', '/');
remotePathParts = rdtPathParts(configuration.remotePath, 'separator', '.');
pathParts = cat(2, repoParts, remotePathParts, {artifactId, version});
remoteUrl = rdtFullPath(pathParts, 'separator', '/');
artifact = rdtArtifact( ...
    'remotePath', remotePath, ...
    'artifactId', artifactId, ...
    'version', version, ...
    'type', type, ...
    'localPath', localPath, ...
    'url', remoteUrl);
