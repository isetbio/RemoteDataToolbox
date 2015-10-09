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

gradlePublishArtifact(repository, username, password, ...
    'test-group1', 'test-artifact1', '1', fullfile(pathHere, 'test-artifact1.txt'));
gradlePublishArtifact(repository, username, password, ...
    'test-group1', 'test-artifact2', '2', fullfile(pathHere, 'test-artifact2.mat'));

gradlePublishArtifact(repository, username, password, ...
    'test-group2', 'test-artifact1', '1', fullfile(pathHere, 'test-artifact1.txt'));
gradlePublishArtifact(repository, username, password, ...
    'test-group2', 'test-artifact2', '2', fullfile(pathHere, 'test-artifact2.mat'));

