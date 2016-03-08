%% This is a tutorial for the Remote Data Toolbox plain-old-function API.
%
% This script shows the effect of the the local artifact cache.  It fetches
% the same artifact more than once and shows the elapsed time for each
% fetch.  The idea is that the first fetch requires an actually download,
% and subsequent fetches are faster.
%
% This script uses a JSON file to configure a Remote Data Toolbox client
% object with things like the Url of the project's remote repository.  This
% simplifies various calls to the Remote Data Toolbox functions.
%
% Copyright (c) 2016 RemoteDataToolbox Team

%% Get a client configured for the isetbio repository.
clear;
clc;

config = rdtConfiguration('isetbio-guest');

%% Choose an arbitrary artifact, about 4MB.
remotePath = 'validation/full/wavefront';
artifactId = 'wvfZernikePolynomials';
version = 'run00001';

%% Remove the cached artifact, if there's one there already.
cached = rdtListLocalArtifacts(config, remotePath, ...
    'artifactId', artifactId, ...
    'version', version);
if ~isempty(cached)
    rdtDeleteLocalArtifacts(config, cached);
end

%% Fetch the artifact more than once, timing each fetch.
fprintf('Fetching artifact with id <%s>.  Fetch #1 should be the slowest.\n', ...
    artifactId);

nIterations = 5;
for ii = 1:nIterations
    tic();
    [data, artifact] = rdtReadArtifact(config, remotePath, artifactId, ...
        'version', version);
    elapsed = toc();
    fprintf('Fetch #%d took %.3f seconds\n', ii, elapsed);
end
