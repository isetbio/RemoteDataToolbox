%% This is a tutorial for the Remote Data Toolbox plain-old-function API.
%
% This script shows how you can access any public Maven repository, like
% the popular open source repository at Maven Central.
%
% This script uses explicit Matlab code to configure the RemoteDataToolbox
% and explicitly passes a configuration struct to each toolbox function
% call.
%
% This plain-old-function API is more verbose than the object-oriented API
% based on RdtClient.  Sometimes verbose and explicit is what you want.
% For example, RdtClient remembers its "working remote directory", which
% can cause unexpected results if you forget to set the working remote
% directory beforehand.  In contrast, the plain-old-function API doesn't
% remember anything, so you can't make this type of mistake.
%
% Copyright (c) 2015 RemoteDataToolbox Team

clear;
clc;

%% Explicit configuration pointing at Maven Central.
configuration = rdtConfiguration( ...
    'serverUrl', 'https://repo1.maven.org/maven2', ...
    'repositoryUrl', 'https://repo1.maven.org/maven2');

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
