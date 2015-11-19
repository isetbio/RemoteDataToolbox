%% This is a tutorial for working with the Remote Data Toolbox.
%
% This script shows how you can access any public Maven repository, like
% the popular open source repository at Maven Central.
%
% This script uses explicit Matlab code to configure the RemoteDataToolbox.
% This adds an argument to each toolbox function call.  But it adds
% flaxibility and allows this script to be self-contained.
%
% Copyright (c) 2015 RemoteDataToolbox Team

clear;
clc;

%% Explicit configuration pointing at Maven Central.
configuration = rdtConfiguration( ...
    'serverUrl', 'http://repo1.maven.org/maven2', ...
    'repositoryUrl', 'http://repo1.maven.org/maven2');

%% Browse the Maven Central repository.

% many open-source Java libraries at Maven Central
rdtOpenBrowser(configuration);

%% Read an arbitrary artifact.

% arbitrary artifact from the Jython project
remotePath = 'jython';
artifactId = 'jython';
version = '2.1';
type = 'pom';
[data, artifact] = rdtReadArtifact(configuration, remotePath, artifactId, ...
    'version', version, ...
    'type', type);

% we got a bit of xml metadata
disp('Got an artifact:');
disp(artifact)

disp(['With "' artifact.type '" data:']);
disp(data)

%% Visit this specific artifact at Maven Central.
rdtOpenBrowser(artifact);
