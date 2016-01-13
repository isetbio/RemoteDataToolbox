function [deleted, notDeleted] = rdtDeleteLocalArtifacts(configuration, artifacts)
%% Delete multiple artifacts from the local artifact cache.
%
% [deleted, notDeleted] = rdtDeleteLocalArtifacts(configuration, artifacts)
% deletes multiple artifacts from the local artifact cache.
% configuration.cacheFolder should point to the root of the local artifact
% cache.  If configuration.cacheFolder is empty, the Gradle  default is
% used ('~/.gradle').
%
% The given artifacts must be a struct array of artifact metadata, with one
% element per artifact to delete.  rdtListLocalArtifacts() returns such a
% struct array.
%
% This function has no effect on a remote server.
%
% Returns a subset of the given artifacts struct array indicating which
% artifacts were actually deleted.  Also returns a subset indicating which
% artifacts were not deleted if any.
%
% See also rdtListLocalArtifacts
%
% [deleted, notDeleted] = rdtDeleteLocalArtifacts(configuration, artifacts)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('configuration');
parser.addRequired('artifacts', @isstruct);
parser.parse(configuration, artifacts);
configuration = rdtConfiguration(parser.Results.configuration);
artifacts = parser.Results.artifacts;

%% Implementation note:
% The configuration parameter is not currently used because we get all the
% information we need from the artifact struct itself.  But I think we
% should still include the configuration parameter.  That way this function
% is consistent with the rest of the RDT API.  Also, we might want to use
% the configuraiton later for some purpose we haven't thought of yet, and
% it might be awkward to change this funciton's interface at that point.
%
% One way we might use the configuration parameter would be to sanity-check
% that configuration.cacheFolder actually contains the given artifacts.

%% Attempt to delete each artifact, one at a time.
nArtifacts = numel(artifacts);
isDeleted = false(1, nArtifacts);
for ii = 1:nArtifacts
    localPath = artifacts(ii).localPath;
    if 2 ~= exist(localPath, 'file')
        fprintf('Artifact file does not exist: <%s>.\n', localPath);
        continue;
    end
    
    checksumFolder = fileparts(localPath);
    if 7 ~= exist(checksumFolder, 'dir')
        fprintf('Artifact folder does not exist: <%s>.\n', checksumFolder);
        continue;
    end
    
    % remove the checksum folder that contains the artifact file.
    [isDeleted(ii), message] = rmdir(checksumFolder, 's');
    if ~isDeleted(ii)
        fprintf('Could not delete artifact <%s>:\n%s\n', message);
    end
end

deleted = artifacts(isDeleted);
notDeleted = artifacts(~isDeleted);
