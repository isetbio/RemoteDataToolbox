%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% This is a tutorial for working with the Remote Data Toolbox.
%
% This script shows how you might query a project's Archiva server to find
% out things like:
%   - What groups of artifacts are available?
%   - What artifacts are in each gruop?
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

%% What groups are available?  These are like repository folders.
[groupIds, repositoryName] = rdtListGroups('brainard-archiva');
nGroups = numel(groupIds);

fprintf('There are %d groups in the repository "%s":\n', nGroups, repositoryName);
disp(groupIds)

%% What artifacts are available in each group?
for ii = 1:nGroups
    groupId = groupIds{ii};
    artifacts = rdtListArtifacts(groupId, 'brainard-archiva');
    nArtifacts = numel(artifacts);
    
    fprintf('Group "%s" contains %d artifacts:\n', groupId, nArtifacts);
    for jj = 1:nArtifacts
        disp(artifacts(jj));
    end
end

%% Which artifacts match the term "demo"?

% should see the same artifact as in rdtExamplePublishData.m

demoArtifacts = rdtSearchArtifacts('demo', '', '', '', '', 'brainard-archiva');
nArtifacts = numel(demoArtifacts);
fprintf('%d artifacts match the term "demo":\n', nArtifacts);
for jj = 1:nArtifacts
    disp(demoArtifacts(jj));
end

%% Which artifacts match the term "test"?
testArtifacts = rdtSearchArtifacts('test', '', '', '', '', 'brainard-archiva');
nArtifacts = numel(testArtifacts);
fprintf('%d artifacts match the term "test":\n', nArtifacts);
for jj = 1:nArtifacts
    disp(testArtifacts(jj));
end

%% Which *text* artifacts match the term "test"?
testTxtArtifacts = rdtSearchArtifacts('test', '', '', '', 'txt', 'brainard-archiva');
nArtifacts = numel(testTxtArtifacts);
fprintf('%d artifacts of type "txt" match the term "test":\n', nArtifacts);
for jj = 1:nArtifacts
    disp(testTxtArtifacts(jj));
end

%% Which *version 2* artifacts match the term "test"?
testV2Artifacts = rdtSearchArtifacts('test', '', '', '2', '', 'brainard-archiva');
nArtifacts = numel(testV2Artifacts);
fprintf('%d artifacts at version 2 match the term "test":\n', nArtifacts);
for jj = 1:nArtifacts
    disp(testV2Artifacts(jj));
end