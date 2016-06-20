%% Publish remote artifacts needed for toolbox tests.
%
% This assumes you have set up an Archiva server.  See the quick start
% guide here:
%   https://archiva.apache.org/docs/1.3.6/quick-start.html
%
% You could set up the server on any host, including your local
% workstation.  Visit the web UI:
%   http://localhost:8080
%
% By default, this script points at a public server called
% brainard-archiva, hosted by UPenn.  Visit the web UI:
%   http://52.32.77.154/
%
% You should create a Maven2 repository with the following name:
%   test-repository
%
% You should create a test user with the following credentials:
%   test:ZeBacu5R
%
% You should give the test user write permissions for the test repository
% (add the repository manager role).
%
% Then run this script to publish the artifacts expected by
% RemoteDataToolbox tests.
%
% Copyright (c) 2015 RemoteDataToolbox Team

clear;
clc;

repository = 'http://52.32.77.154/repository/test-repository';
username = 'test';
password = 'ZeBacu5R';

pathHere = fileparts(mfilename('fullpath'));

remotePath = 'test-group-1';
gradlePublishArtifact(repository, username, password, ...
    remotePath, 'image-artifact', '1', fullfile(pathHere, 'image-artifact.jpg'));
gradlePublishArtifact(repository, username, password, ...
    remotePath, 'json-artifact', '2', fullfile(pathHere, 'json-artifact.json'));
gradlePublishArtifact(repository, username, password, ...
    remotePath, 'matlab-artifact', '3', fullfile(pathHere, 'matlab-artifact.mat'));
gradlePublishArtifact(repository, username, password, ...
    remotePath, 'text-artifact', '4', fullfile(pathHere, 'text-artifact.txt'));

remotePath = 'test-group-2';
gradlePublishArtifact(repository, username, password, ...
    remotePath, 'image-artifact', '1', fullfile(pathHere, 'image-artifact.jpg'));
gradlePublishArtifact(repository, username, password, ...
    remotePath, 'json-artifact', '2', fullfile(pathHere, 'json-artifact.json'));
gradlePublishArtifact(repository, username, password, ...
    remotePath, 'matlab-artifact', '3', fullfile(pathHere, 'matlab-artifact.mat'));
gradlePublishArtifact(repository, username, password, ...
    remotePath, 'text-artifact', '4', fullfile(pathHere, 'text-artifact.txt'));
