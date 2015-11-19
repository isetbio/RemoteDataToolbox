function [datas, artifacts] = rdtReadArtifacts(configuration, artifacts)
%% Fetch multiple artifacts from a remote repository an read them into Matlab.
%
% [datas, artifacts] = rdtReadArtifacts(configuration, artifacts) fetches
% multiple artifacts from a remote respository and loads each into a Matlab
% variable.  configuration.repositoryUrl must point to the repository root.
%
% The given artifacts must be a struct array of artifact metadata, with one
% element per artifact to fetch.  rdtListArtifacts() and
% rdtSearchArtifacts() return suitable struct arrays.
%
% Returns a cell array of loaded Matlab data with one element per artifact.
% rdtFetchArtifact describes the expected data formats.  Also returns the
% given artifacts struct array with some local data filled in.
%
% See also rdtFetchArtifact rdtListArtifacts rdtSearchArtifacts
%
% [datas, artifacts] = rdtReadArtifacts(configuration, artifacts)
%
% Copyright (c) 2015 RemoteDataToolbox Team

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
