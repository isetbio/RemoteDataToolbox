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
% artifact = rdtPublishArtifact( ... 'description', description) adds
% the given description to the artifact metadata.  The default is no
% description.
%
% artifact = rdtPublishArtifact( ... 'name', name) adds the given
% name to the artifact metadata.  The default is no name.
%
% artifact = rdtPublishArtifact( ... 'deleteLocal', deleteLocal) choose
% whether to delete the artifact from the local cache after publishing.
% The default is false, leave the artifact in the local cache.
%
% artifact = rdtPublishArtifact( ... 'rescan', rescan) choose
% whether to request the remote repository to update its artifact listing
% and search index.  The default is true -- rescan and update.
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
parser.addParameter('description', '', @ischar);
parser.addParameter('name', '', @ischar);
parser.addParameter('deleteLocal', false, @islogical);
parser.addParameter('rescan', true, @islogical);
parser.parse(configuration, file, remotePath, varargin{:});
configuration = rdtConfiguration(parser.Results.configuration);
file = parser.Results.file;
remotePath = parser.Results.remotePath;
artifactId = parser.Results.artifactId;
version = parser.Results.version;
description = parser.Results.description;
name = parser.Results.name;
deleteLocal = parser.Results.deleteLocal;
rescan = parser.Results.rescan;

if isempty(artifactId)
    [~, artifactId] = fileparts(file);
end

artifact = [];

%% Publish the artifact.
[localPath, pomPath, type] = gradlePublishArtifact(configuration.repositoryUrl, ...
    configuration.username, ...
    configuration.password, ...
    rdtPathSlashesToDots(remotePath), ...
    artifactId, ...
    version, ...
    file, ...
    'cacheFolder', configuration.cacheFolder, ...
    'verbose', logical(configuration.verbosity), ...
    'description', description, ...
    'name', name);

if isempty(localPath)
    return;
end

%% Ask the remote server to rescan the repository?
if rescan
    rdtRequestRescan(configuration);
end

%% Read more metadata from the artifact pom.
fid = fopen(pomPath, 'r');
if fid < 0
    description = '';
    name = '';
else
    xmlString = fread(fid, '*char')';
    description = rdtScrapeXml(xmlString, 'description', '');
    name = rdtScrapeXml(xmlString, 'name', '');
    fclose(fid);
end

%% Build an artifact struct for the fetched artifact.
remoteUrl = rdtBuildArtifactUrl(configuration.repositoryUrl, remotePath, artifactId, version, localPath);
artifact = rdtArtifact( ...
    'remotePath', remotePath, ...
    'artifactId', artifactId, ...
    'version', version, ...
    'type', type, ...
    'localPath', localPath, ...
    'url', remoteUrl, ...
    'description', description, ...
    'name', name);

%% Optionally clean up the local cache.
if deleteLocal
    rdtDeleteLocalArtifacts(configuration, artifact);
    artifact.localPath = '';
end
