function [deleted, notDeleted] = rdtDeleteArtifacts(configuration, artifacts, varargin)
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
% artifact = rdtDeleteArtifacts( ... 'rescan', rescan) choose
% whether to request the remote repository to update its artifact listing
% and search index.  The default is true -- rescan and update.
%
% artifact = rdtDeleteArtifacts( ... 'allFiles', allFiles) choose
% whether to delete all files associated with each given artifact.  This
% includes artifact metadata and all data files of any type.  The default
% is false, only delete one file at a time as specified by artifact.type.
%
% Returns a subset of the given artifacts struct array indicating which
% artifacts were actually deleted from the remote server.  Also returns a
% subset indicating which artifacts were not deleted if any.
%
% See also rdtListArtifacts rdtSearchArtifacts rdtDeleteLocalArtifacts
%
% [deleted, notDeleted] = rdtDeleteArtifacts(configuration, artifacts, varargin)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('configuration');
parser.addRequired('artifacts', @isstruct);
parser.addParameter('rescan', true, @islogical);
parser.addParameter('allFiles', false, @islogical);
parser.parse(configuration, artifacts, varargin{:});
configuration = rdtConfiguration(parser.Results.configuration);
artifacts = parser.Results.artifacts;
rescan = parser.Results.rescan;
allFiles = parser.Results.allFiles;

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
    isDeleted(ii) = archivaDeleteArtifact(configuration, artifacts(ii), allFiles);
    
    % try to delete from local cache
    if allFiles
        foundLocally = rdtListLocalArtifacts(configuration, ...
            artifacts(ii).remotePath, ...
            'artifactId', artifacts(ii).artifactId, ...
            'version', artifacts(ii).version);
    else
        foundLocally = rdtListLocalArtifacts(configuration, ...
            artifacts(ii).remotePath, ...
            'artifactId', artifacts(ii).artifactId, ...
            'version', artifacts(ii).version, ...
            'type', artifacts(ii).type);
    end
    if ~isempty(foundLocally)
        rdtDeleteLocalArtifacts(configuration, foundLocally);
    end
end

deleted = artifacts(isDeleted);
notDeleted = artifacts(~isDeleted);

%% Ask the remote server to rescan the repository?
if rescan
    rdtRequestRescan(configuration);
end

% Ask Archiva to delete an artifact.
function isDeleted = archivaDeleteArtifact(configuration, artifact, allFiles)
configuration.acceptMediaType = 'text/plain';
resourcePath = '/restServices/archivaServices/repositoriesService/deleteArtifact';
deleteRequest = struct( ...
    'repositoryId', configuration.repositoryName, ...
    'version', artifact.version, ...
    'artifactId', artifact.artifactId, ...
    'groupId', rdtPathSlashesToDots(artifact.remotePath));

if ~allFiles
    deleteRequest.classifier = artifact.type;
    deleteRequest.packaging = artifact.type;
end

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
