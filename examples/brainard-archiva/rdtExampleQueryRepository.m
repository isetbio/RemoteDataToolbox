%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% This is a tutorial for working with the Remote Data Toolbox.
%
% This script shows how you might query a project's Archiva server to find
% out things like:
%   - What remote paths to artifacts are available?
%   - What artifacts are located under each remote path?
%   - What artifacts match a search term?
%
% This script uses a JSON file to configure the Remote Data Toolbox with
% things like the Url of the project's Archiva server.  This simplifies
% various calls to the Remote Data Toolbox functions.
%
% This script does not require you to enter repository credentials because
% all we are doing is querying for artifacts that someone else published.
% We can do this with the default "guest" account.
%
% See the rdtExamplePublishData.m to see how to publish data in the
% first place.
%
% @ingroup examples

clear;
clc;

%% What remote paths are available?
[remotePaths, repositoryName] = rdtListRemotePaths('brainard-archiva');
nPaths = numel(remotePaths);

fprintf('There are %d remote paths in the repository "%s":\n', nPaths, repositoryName);
disp(remotePaths)

%% What artifacts are available under each remote path?
for ii = 1:nPaths
    remotePath = remotePaths{ii};
    artifacts = rdtListArtifacts('brainard-archiva', remotePath);
    nArtifacts = numel(artifacts);
    
    fprintf('Remote path "%s" contains %d artifacts:\n', remotePath, nArtifacts);
    for jj = 1:nArtifacts
        disp(artifacts(jj));
    end
end

%% Which artifacts match the term "demo"?

% should see the same artifact as in rdtExamplePublishData.m

demoArtifacts = rdtSearchArtifacts('brainard-archiva', 'demo');
nArtifacts = numel(demoArtifacts);
fprintf('%d artifacts match the term "demo":\n', nArtifacts);
for jj = 1:nArtifacts
    disp(demoArtifacts(jj));
end

%% Which artifacts match the term "test"?
testArtifacts = rdtSearchArtifacts('brainard-archiva', 'test');
nArtifacts = numel(testArtifacts);
fprintf('%d artifacts match the term "test":\n', nArtifacts);
for jj = 1:nArtifacts
    disp(testArtifacts(jj));
end

%% Which *text* artifacts match the term "test"?
testTxtArtifacts = rdtSearchArtifacts('brainard-archiva', 'test', 'type', 'txt');
nArtifacts = numel(testTxtArtifacts);
fprintf('%d artifacts of type "txt" match the term "test":\n', nArtifacts);
for jj = 1:nArtifacts
    disp(testTxtArtifacts(jj));
end

%% Which *version 2* artifacts match the term "test"?
testV2Artifacts = rdtSearchArtifacts('brainard-archiva', 'test', 'version', '2');
nArtifacts = numel(testV2Artifacts);
fprintf('%d artifacts at version 2 match the term "test":\n', nArtifacts);
for jj = 1:nArtifacts
    disp(testV2Artifacts(jj));
end