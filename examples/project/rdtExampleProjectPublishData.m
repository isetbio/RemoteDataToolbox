%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% This is a tutorial for working with the Remote Data Toolbox.
%
% This script shows how you might generate some data as part of a project
% and publish that data as an artifact to the project's Maven repository.
%
% This script uses a JSON file to configure the Remote Data Toolbox with
% things like the Url of the project's Maven repository.  This simplifies
% various calls to the Remote Data Toolbox functions.
%
% You probably don't want to store your project's repository credentials in
% a JSON file, because others would be able to read it.  So before
% publishing data, this script will prompt you to enter a password into a
% dialog window.  For this demo, use the user name "demo" and password
% "pa55w0rd".
%
% See the rdtExampleProjectReadData.m to see how to read data that's
% already been published.
%
% @ingroup examples

clear;
clc;

%% Generate an image.

% generate some random data and save it as an image.
row = 1 + floor((0:499) / 50);
indexes = repmat(row, 500, 1);
colors = jet(10);
colors = colors(randperm(10), :);
imageFile = fullfile(tempdir(), 'my-image.png');
imwrite(indexes, colors, imageFile, 'png');

% view the image
imshow(imageFile)

%% Get repository configuration and credentials.

% cd to "project" folder so RemodeDataToolbox can locate JSON configuration
thisFolder = fileparts(which('rdtExampleProjectPublishData'));
cd(thisFolder);

% enter credentials (demo:pa55w0rd) to complete the configuration
configuration = rdtCredentialsDialog();

%% Publish the image as an artifact.

% each artifact must belong to a group, which is like a folder
groupId = 'project-demo';

% each artifact must have an artifactId, which is like a file name
artifactId = 'demo-image';

% each artifact must have a version, the default is version '1'
version = '42';

% supply the configuration, which now contains publishing credentials
artifact = rdtPublishArtifact(imageFile, ...
    groupId, ...
    artifactId, ...
    version, ...
    configuration);

%% See metadata about the new artifact!
disp(artifact)

%% Visit the new artifact on the web!

% you may need to enter your credentials again (demo:pa55w0rd)
web(artifact.url, '-browser')
