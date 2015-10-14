%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Fetch multiple artifacts from a Maven repository an read them into Matlab.
%   @param artifacts struct array of artifact metadata
%   @param configuration optional RemoteDataToolbox configuration struct
%
% @details
% Fetches multiple artifacts from a Maven respository, caches each in the
% local file system, and loads each into a Matlab variable.  If @a
% configuration is provided, queries the server at @a
% configuration.repository.  Otherwise, uses the configuration returned
% from rdtConfiguration().
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
%   artifacts = rdtListGroups(configuration)
%
% @ingroup utilities
function [datas, artifacts] = rdtReadArtifacts(artifacts, configuration)

if nargin < 2 || isempty(configuration)
    configuration = rdtConfiguration();
else
    configuration = rdtConfiguration(configuration);
end

% TODO: optimize the multiple-artifact fetch by including all artifacts in
% a single invocation of Gradle.  This should remove significant overhead
% from Gradle startup and network "chattiness".  We just have to figure out
% a good way to pass multiple artifacts to fetch.gradle.
nArtifacts = numel(artifacts);
datas = cell(1, nArtifacts);
for ii = 1:nArtifacts
    artifact = artifacts(ii);
    [datas{ii}, artifacts(ii)] = rdtReadArtifact(artifact.groupId, ...
        artifact.artifactId, ...
        artifact.version, ...
        artifact.type, ...
        configuration);
end
