%% This is a tutorial for the Remote Data Toolbox object-oriented API.
%
% This script shows how you can publish multiple artifacts at once.
%
% Most of the artifacts correspond to one file each.  There is also a group
% of files called "multiple-flavor" which are published into a single
% artifact.  This happens because they share the same file name, but have
% different file extensions.  This is allowed!
%
% This script lists and searches for the artifacts after publishing them.
% We can run the list and search over all artifacts, or restrict the
% results to certain file types.
%
% This script uses a JSON file to configure a Remote Data Toolbox client
% object with things like the Url of the project's remote repository.  This
% simplifies various calls to the Remote Data Toolbox functions.
%
% You probably don't want to store your project's repository credentials in
% a JSON file, because others would be able to read it.  So before
% publishing data, this script will prompt you to enter a password into a
% dialog window.  For this demo, use the user name "test" and password
% "ZeBacu5R".
%
% For wonks who may be interested: multiple files within one artifact are
% distinguished using the Maven concept of a "classifier".  For
% RemoteDataToolbox we impose that the classifier is always equal to the
% file extension.  For more wonkish background, scroll down a bit in this
% section of the Maven docs:
%  https://maven.apache.org/pom.html#Dependencies
%
% See also rdtExampleReadData, rdtPublishArtifacts
%
% Copyright (c) 2015 RemoteDataToolbox Team

clear;
clc;

%% Choose a folder with a collection of files to publish.
sourceFolder = fullfile(rdtRootPath(), 'test', 'testArtifacts');
sources = dir(sourceFolder);
nSources = numel(sources);

% minus 2: don't count "." and ".." as sources
fprintf('We are about to publish a collection of %d files:\n', nSources - 2);
for ii = 1:nSources
    name = sources(ii).name;
    if strcmp('.', name) || strcmp('..', name)
        continue;
    end
    fprintf('  %s\n', name);
end

%% Create a client object with project configuration and credentials.
client = RdtClient('brainard-archiva');
client.credentialsDialog();

% this is where the artifacts will go in the remote repository
client.crp('/publish-multiple');

%% Publish the collection!
artifacts = client.publishArtifacts(sourceFolder);
nArtifacts = numel(artifacts);
fprintf('We just published a collection of %d files.\n', nArtifacts);

%% List all the artifacts.
listed = client.listArtifacts();
nListed = numel(listed);
fprintf('List of all artifacts includes %d:\n', nListed);
for ii = 1:nListed
    fprintf('  %s %s\n', listed(ii).artifactId, listed(ii).type);    
end

%% List all the "txt" artifacts.
listedTxt = client.listArtifacts('type', 'txt');
nListedTxt = numel(listedTxt);
fprintf('List of "txt" artifacts includes %d:\n', nListedTxt);
for ii = 1:nListedTxt
    fprintf('  %s %s\n', listedTxt(ii).artifactId, listedTxt(ii).type);    
end

%% Search for artifacts matching the term "classifier".
foundFlavor = client.searchArtifacts('flavor');
nFoundFlavor = numel(foundFlavor);
fprintf('Search for "flavor" turned up %d:\n', nFoundFlavor);
for ii = 1:nFoundFlavor
    fprintf('  %s %s\n', foundFlavor(ii).artifactId, foundFlavor(ii).type);    
end

%% Search for "txt" artifacts matching the term "classifier".
foundFlavorTxt = client.searchArtifacts('flavor', 'type', 'txt');
nFoundFlavorTxt = numel(foundFlavorTxt);
fprintf('Search for "flavor" of type "txt" turned up %d:\n', nFoundFlavorTxt);
for ii = 1:nFoundFlavorTxt
    fprintf('  %s %s\n', foundFlavorTxt(ii).artifactId, foundFlavorTxt(ii).type);    
end

