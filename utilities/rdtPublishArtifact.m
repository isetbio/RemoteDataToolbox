%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Publish an artifact to a Maven repository.
%   @param file local name or path to the file to publish as an artifact
%   @param groupId string id of the artifact's group (required)
%   @param artifactId string id of the artifact itself (defaults to file name)
%   @param version string artifact version (defaults to '1')
%   @param configuration optional RemoteDataToolbox configuration struct
%
% @details
% Publishes the given @a file as artifact to a Maven respository.  If @a
% configuration is provided, publishes to the server at @a
% configuration.repository.  Otherwise, uses the configuration returned
% from rdtConfiguration().
%
% @details
% Returns a struct of metadata about the published artifact, including its
% groupId, artifactId, server url, and local file path within the artifact
% cache.  See rdtArtifact().
%
% @details
% If the publication fails, returns [].
%
% @details
% Usage:
%   artifact = rdtPublishArtifact(file, groupId, artifactId, version, configuration)
%
% @ingroup utilities
function artifact = rdtPublishArtifact(file, groupId, artifactId, version, configuration)

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
    groupId, ...
    artifactId, ...
    version, ...
    file);

if isempty(localPath)
    return;
end

%% Build an artifact struct for the fetched artifact.
remoteUrl = [configuration.repositoryUrl '/' groupId '/' artifactId '/' version];
artifact = rdtArtifact( ...
    'groupId', groupId, ...
    'artifactId', artifactId, ...
    'version', version, ...
    'type', type, ...
    'localPath', localPath, ...
    'url', remoteUrl);
