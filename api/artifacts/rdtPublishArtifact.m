%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Publish an artifact to a remote repository.
%   @param configuration RemoteDataToolbox configuration info
%   @param file local name or path to the file to publish as an artifact
%   @param remotePath string remote path to the artifact (required)
%   @param artifactId string id of the artifact itself (defaults to file name)
%   @param version string artifact version (defaults to '1')
%
% @details
% Publishes the given @a file as an artifact to a remote respository.  @a
% configuration.repositoryUrl should point to the repository root.
%
% @details
% Returns a struct of metadata about the published artifact, including its
% remotePath, artifactId, server url, and local file path within the
% artifact cache.  See rdtArtifact().
%
% @details
% If the publication fails, returns [].
%
% @details
% Usage:
%   artifact = rdtPublishArtifact(configuration, file, remotePath, artifactId, version)
%
% @ingroup artifacts
function artifact = rdtPublishArtifact(configuration, file, remotePath, varargin)

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
remoteUrl = [configuration.repositoryUrl '/' remotePath '/' artifactId '/' version];
artifact = rdtArtifact( ...
    'remotePath', remotePath, ...
    'artifactId', artifactId, ...
    'version', version, ...
    'type', type, ...
    'localPath', localPath, ...
    'url', remoteUrl);
