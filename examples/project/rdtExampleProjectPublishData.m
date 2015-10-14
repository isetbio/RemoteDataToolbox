%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% This is a step-by step example for working with the Remote Data Toolbox.
%
% This script shows how you might generate some data as part of a project
% and publish that data to a Maven repository as an artifact.
%
% This script uses a JSON file to configure the Remote Data Toolbox with
% things like the Url of your server.  This simplifies all the calls to the
% Remote Data Toolbox functions.
%
% You probably don't want to store your repository account credentials in a
% JSON file, because others would be able to read it.  So before publishing
% data, this script will prompt you to enter a password into a dialog box.
% For the purposes of this demo, you should enter the password "pa55w0rd".
%
% See the rdtExampleProjectReadData to see how to read data that's already
% been published.
%
% @ingroup examples

clear;
clc;

%% Generate an image.

% generate some random data and save it as an image.
imageData = uint8(100 * eye(500) + randi(100, [500 500]));
imageFile = fullfile(tempdir(), 'my-image.png');
imwrite(imageData, imageFile, 'png');

% view the image
imshow(imageFile)

%% Get repository configuration and credentials.

% cd to "project" folder so RemodeDataToolbox can locate JSON configuration
thisFolder = fileparts(which('rdtExampleProjectPublishData'));
cd(thisFolder);

% prompt for credentials to complete the configuration
configuration = rdtCredentialsDialog();

%% Publish the image as an artifact.

% each artifact must belong to a group, which is like a folder
groupId = 'project-demo';

% each artifact must have an artifactId, which is like a file name
artifactId = 'demo-image';

% each artifact must have a version, the default is version '1'
version = '42';

% supply the configuration, which contains publishing credentials
artifact = rdtPublishArtifact(imageFile, ...
    groupId, ...
    artifactId, ...
    version, ...
    configuration);

% see metadata about the new artifact!
disp(artifact)

% see the artifact in your browser!
web(artifact.url, '-browser')
