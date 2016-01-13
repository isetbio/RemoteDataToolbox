function [deleted, notDeleted] = rdtDeleteArtifacts(configuration, artifacts)
%% Delete multiple artifacts from a remote server and the local cache.
%
% [deleted, notDeleted] = rdtDeleteArtifacts(configuration, artifacts)
% deletes multiple artifacts from a remote server and from the local
% artifact cache.  configuration.repositoryUrl must point to the repository
% root.  configuration.cacheFolder should point to the root of the
% local artifact cache.  If configuration.cacheFolder is empty, the Gradle
% default is used ('~/.gradle').
%
% The given artifacts must be a struct array of artifact metadata, with one
% element per artifact to delete.  rdtListArtifacts() and
% rdtSearchArtifacts() return such struct arrays.
%
% Returns a subset of the given artifacts struct array indicating which
% artifacts were actually deleted from the remote server.  Also returns a
% subset indicating which artifacts were not deleted if any.
%
% See also rdtListArtifacts rdtSearchArtifacts rdtDeleteLocalArtifacts
%
% [deleted, notDeleted] = rdtDeleteArtifacts(configuration, artifacts)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('configuration');
parser.addRequired('artifacts', @isstruct);
parser.parse(configuration, artifacts);
configuration = rdtConfiguration(parser.Results.configuration);
artifacts = parser.Results.artifacts;

%% Implementation note:
% This delete operation is implemented in an Archiva-specific way.  So from
% an implementation point of view, I would like to put this function in the
% api/queries folder along with other functions that use the Archiva
% RESTful API.
%
% But from a user point of view, it seems right to put this function here
% in api/artifacts along with other functions related to the artifact
% lifecycle.

%% Attempt to delete each artifact, one at a time.
nArtifacts = numel(artifacts);
isDeleted = false(1, nArtifacts);
for ii = 1:nArtifacts
    % try to delete from remote server
    isDeleted(ii) = archivaDeleteArtifact(configuration, artifacts(ii));
    
    % try to delete from local cache
    foundLocally = rdtListLocalArtifacts(configuration, ...
        artifacts(ii).remotePath, ...
        'artifactId', artifacts(ii).artifactId, ...
        'version', artifacts(ii).version, ...
        'type', artifacts(ii).type);
    if ~isempty(foundLocally)
        rdtDeleteLocalArtifacts(configuration, foundLocally);
    end
end

deleted = artifacts(isDeleted);
notDeleted = artifacts(~isDeleted);

% Ask Archiva to delete an artifact.
function isDeleted = archivaDeleteArtifact(configuration, artifact)
configuration.acceptMediaType = 'text/plain';
resourcePath = '/restServices/archivaServices/repositoriesService/deleteArtifact';
deleteRequest = struct( ...
    'repositoryId', configuration.repositoryName, ...
    'version', artifact.version, ...
    'artifactId', artifact.artifactId, ...
    'groupId', rdtPathSlashesToDots(artifact.remotePath), ...
    'classifier', artifact.type, ...
    'packaging', artifact.type);

try
    message = rdtRequestWeb(configuration, resourcePath, 'requestBody', deleteRequest);
    isDeleted = strcmpi('true', message);
catch ex
    isDeleted = false;
    message = ex.message;
end

if ~isDeleted
    fprintf('Could not delete remote artifact <%s>:\n%s\n', artifact.url, message);
    fprintf('Does your configuration have good credentials?\n');
end
