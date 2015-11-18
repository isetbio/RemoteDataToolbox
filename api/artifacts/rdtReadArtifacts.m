%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Fetch multiple artifacts from a remote repository an read them into Matlab.
%   @param configuration RemoteDataToolbox configuration info
%   @param artifacts struct array of artifact metadata
%
% @details
% Fetches multiple artifacts from a remote respository, caches each in the
% local file system, and loads each into a Matlab variable.  @a
% configuration.repositoryUrl should point to the repository root.
%
% @details
% @a artifacts must be a struct array of artifact metadata, with one
% element per artifact to fetch.  See rdtArtifact() for the expected fields
% of the struct array. See also rdtListArtifacts() and
% rdtSearchArtifacts(), which return such struct arrays.
%
% @details
% Returns a cell array of data loaded from each artifact.  See
% rdtReadArtifact() for the expected data formats.
%
% @details
% Also returns a the given @a artifacts, with local file paths filled in.
%
% @details
% Usage:
%   [datas, artifacts] = rdtReadArtifacts(configuration, artifacts)
%
% @ingroup artifacts
function [datas, artifacts] = rdtReadArtifacts(configuration, artifacts)

parser = rdtInputParser();
parser.addRequired('configuration');
parser.addRequired('artifacts', @isstruct);
parser.parse(configuration, artifacts);
configuration = rdtConfiguration(parser.Results.configuration);
artifacts = parser.Results.artifacts;

% TODO: optimize the multiple-artifact fetch by including all artifacts in
% a single invocation of Gradle.  This should remove significant overhead
% from Gradle startup and network "chattiness".  We just have to figure out
% a good way to pass multiple artifacts to fetch.gradle.
nArtifacts = numel(artifacts);
datas = cell(1, nArtifacts);
for ii = 1:nArtifacts
    artifact = artifacts(ii);
    [datas{ii}, artifacts(ii)] = rdtReadArtifact(configuration, ...
        artifact.remotePath, ...
        artifact.artifactId, ...
        'version', artifact.version, ...
        'type', artifact.type);
end
