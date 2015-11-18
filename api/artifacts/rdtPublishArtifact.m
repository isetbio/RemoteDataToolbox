%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Publish an artifact to a remote repository.
%   @param file local name or path to the file to publish as an artifact
%   @param remotePath string remote path to the artifact (required)
%   @param artifactId string id of the artifact itself (defaults to file name)
%   @param version string artifact version (defaults to '1')
%   @param configuration optional RemoteDataToolbox configuration struct
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
%   artifact = rdtPublishArtifact(file, remotePath, artifactId, version, configuration)
%
% @ingroup artifacts
function artifact = rdtPublishArtifact(file, remotePath, artifactId, version, configuration)

artifact = [];

if nargin < 3 || isempty(artifactId)
    artifactId = '';
end

if nargin < 4 || isempty(version)
    version = '1';
end

if nargin < 5 || isempty(configuration)
    configuration = rdtConfiguration();
else
    configuration = rdtConfiguration(configuration);
end

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
