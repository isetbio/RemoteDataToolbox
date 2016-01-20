%% Test upload and delete from the archiva server for the pull request
%
% Main point is to ask Ben what I am doing wrong, or to figure out that
% this is the expected behavior.  In either case, it works well enough that
% I will do the merge.
%
% BW, ISETBIO Team

%
close all
clear all

%%
rd = RdtClient('scien');
rd.credentialsDialog;

%% Upload a file to briefTest directory

rd.crp('/briefTest');
fullFile = fullfile(rdtRootPath,'test','testArtifacts','image-artifact.jpg');
exist(fullFile,'file');
rd.publishArtifact(fullFile,'type','jpg');

a = rd.listArtifacts;
disp('This artifact found')
a.artifactId

% Poke around
rd.openBrowser;

%% Remove the file

deleted = rdtDeleteArtifacts(rd.configuration, a);

% This returns an empty artifact, which is good
a = rd.listArtifacts;
if isempty(a)
    disp('Artifact successfully deleted')
end

% The pom file and related (md6, sha1, xml) are still there

%% Now, test triggering a rescan

% Ask for a rescan - not sure what this does ...
[isStarted,message] = rd.requestRescan;
if isStarted
    disp('Rescan is initiated')
end

% Poke around.  In my case, I see a lot of files.
rd.openBrowser;

%% But the artifact is invisible
rd.crp('/');
a = rd.listArtifacts('remotePath','briefTest');
if isempty(a)
    disp('No artifacts in the briefTest directory')
end

% Is that the expected behavior?  When do the pom, md5, and other files go
% away?

%%

