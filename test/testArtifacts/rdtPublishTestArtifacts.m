%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% This script will help you set up an Archiva server suitable for testing
% the RemoteDataToolbox.
%
% This assumes you have set up an Archiva server on the local host.  See
% the quick start guide here:
%   https://archiva.apache.org/docs/1.3.6/quick-start.html
%
% Visit the server in your browser at
%   http://localhost:8080
%
% Create the default admin user with the following credentials:
%   admin:pa55w0rd
%
% Create a Maven2 repository with the following name:
%   test-repository
%
% Then run this script to publish the artifacts expected by
% RemoteDataToolbox tests.
%

clear;
clc;

repository = 'http://localhost:8080/repository/test-repository';
username = 'admin';
password = 'pa55w0rd';

pathHere = fileparts(mfilename('fullpath'));

groupId = 'test-group-1';
gradlePublishArtifact(repository, username, password, ...
    groupId, 'image-artifact', '1', fullfile(pathHere, 'image-artifact.jpg'));
gradlePublishArtifact(repository, username, password, ...
    groupId, 'json-artifact', '2', fullfile(pathHere, 'json-artifact.json'));
gradlePublishArtifact(repository, username, password, ...
    groupId, 'matlab-artifact', '3', fullfile(pathHere, 'matlab-artifact.mat'));
gradlePublishArtifact(repository, username, password, ...
    groupId, 'text-artifact', '4', fullfile(pathHere, 'text-artifact.txt'));

groupId = 'test-group-2';
gradlePublishArtifact(repository, username, password, ...
    groupId, 'image-artifact', '1', fullfile(pathHere, 'image-artifact.jpg'));
gradlePublishArtifact(repository, username, password, ...
    groupId, 'json-artifact', '2', fullfile(pathHere, 'json-artifact.json'));
gradlePublishArtifact(repository, username, password, ...
    groupId, 'matlab-artifact', '3', fullfile(pathHere, 'matlab-artifact.mat'));
gradlePublishArtifact(repository, username, password, ...
    groupId, 'text-artifact', '4', fullfile(pathHere, 'text-artifact.txt'));
