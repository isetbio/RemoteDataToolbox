%% This is a tutorial for the Remote Data Toolbox object-oriented API.
%
% This script shows how you might query a project's Archiva server to find
% out things like:
%   - What remote paths to artifacts are available?
%   - What artifacts are located under each remote path?
%   - What artifacts match a search term?
%
% This script uses a JSON file to configure a Remote Data Toolbox client
% object with things like the Url of the project's remote repository.  This
% simplifies various calls to the Remote Data Toolbox functions.
%
% This script does not require you to enter repository credentials because
% all we are doing is querying for artifacts that someone else published.
% We can do this with the default "guest" account.
%
% See also rdtExamplePublishData
%
% Copyright (c) 2015 RemoteDataToolbox Team

clear;
clc;

%% Get a client configured for our repository.
client = RdtClient('brainard-archiva');

%% What remote paths are available?
remotePaths = client.listRemotePaths();
nPaths = numel(remotePaths);

fprintf('There are %d remote paths in the repository "%s":\n', ...
    nPaths, ...
    client.configuration.repositoryName);
disp(remotePaths)

%% What artifacts are available under each remote path?
for ii = 1:nPaths
    client.crp(fullfile('/',remotePaths{ii}));
    artifacts = client.listArtifacts();
    nArtifacts = numel(artifacts);
    
    fprintf('Remote path "%s" contains %d artifacts:\n', client.pwrp(), nArtifacts);
    for jj = 1:nArtifacts
        disp(artifacts(jj));
    end
end

%% Which artifacts match the term "demo"?
% should see our image artifact from rdtExamplePublishData.m

% change to repository root so we don't miss any artifacts
client.crp('/');

demoArtifacts = client.searchArtifacts('demo');
nArtifacts = numel(demoArtifacts);
fprintf('%d artifacts match the term "demo":\n', nArtifacts);
for jj = 1:nArtifacts
    disp(demoArtifacts(jj));
end

%% Which artifacts match the term "test"?
testArtifacts = client.searchArtifacts('test');
nArtifacts = numel(testArtifacts);
fprintf('%d artifacts match the term "test":\n', nArtifacts);
for jj = 1:nArtifacts
    disp(testArtifacts(jj));
end

%% Which *text* artifacts match the term "test"?
testTxtArtifacts = client.searchArtifacts('test', 'type', 'txt');
nArtifacts = numel(testTxtArtifacts);
fprintf('%d artifacts of type "txt" match the term "test":\n', nArtifacts);
for jj = 1:nArtifacts
    disp(testTxtArtifacts(jj));
end

%% Which *version 2* artifacts match the term "test"?
testV2Artifacts = client.searchArtifacts('test', 'version', '2');
nArtifacts = numel(testV2Artifacts);
fprintf('%d artifacts at version 2 match the term "test":\n', nArtifacts);
for jj = 1:nArtifacts
    disp(testV2Artifacts(jj));
end