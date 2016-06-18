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
rd = RdtClient('isetbio');
rd.credentialsDialog;

%% Upload a file to briefTest directory

rd.crp('/briefTest');
fullFile = fullfile(rdtRootPath,'test','testArtifacts','image-artifact.jpg');
exist(fullFile,'file');
rd.publishArtifact(fullFile,'type','jpg');

a = rd.listArtifacts;
disp('This artifact found')
a.artifactId

% BSH: let's look specifically at the image-artifact version 1 folder
% it should contain the jpg and various metadata files
artifactFolderHack = rdtArtifact('url', fileparts(a.url));
rd.openBrowser(artifactFolderHack);

%% Remove the file

% BSH: try again with the new 'allFiles' flag
deleted = rdtDeleteArtifacts(rd.configuration, a, 'allFiles', true);

% This returns an empty artifact, which is good
a = rd.listArtifacts;
if isempty(a)
    disp('Artifact successfully deleted')
end

%BSH: The pom file and related (md6, sha1, xml) that we say above should
%have been deleted.

%% Now, test triggering a rescan

% Ask for a rescan - not sure what this does ...

% BSH: rdtDeleteArtifacts() already should have rescanned automatically.
% And if listArtifacts() above returned empty, then the rescan was
% successful.  So this rescan here is redundant but harmless.

[isStarted,message] = rd.requestRescan;
if isStarted
    disp('Rescan is initiated')
end

% now the whole artifact is gone!
%   expect a 404 error
rd.openBrowser(artifactFolderHack);

%% But the artifact is invisible
rd.crp('/');
a = rd.listArtifacts('remotePath','briefTest');
if isempty(a)
    disp('No artifacts in the briefTest directory')
end

% Is that the expected behavior?  When do the pom, md5, and other files go
% away?

% BSH with the allFiles flag to rdtDeleteArtifacts(), we can make a whole
% folder go away, including the pom, data files, and other metadata

% BSH but there is still a mostly-empty folder that we might have to live
% with

% still see a folder named briefTest/image-artifact/  :(
rd.openBrowser();

