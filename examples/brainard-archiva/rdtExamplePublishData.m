%% This is a tutorial for working with the Remote Data Toolbox.
%
% This script shows how you might generate some data as part of a project
% and publish that data as an artifact to the project's remote data
% repository.
%
% This script uses a JSON file to configure the Remote Data Toolbox with
% things like the Url of the project's remote repository.  This simplifies
% various calls to the Remote Data Toolbox functions.
%
% You probably don't want to store your project's repository credentials in
% a JSON file, because others would be able to read it.  So before
% publishing data, this script will prompt you to enter a password into a
% dialog window.  For this demo, use the user name "test" and password
% "test123".
%
% See also rdtExampleReadData
%
% Copyright (c) 2015 RemoteDataToolbox Team

clear;
clc;

%% Generate an image.

% generate some random data and save it as an image.
row = 1 + floor((0:499) / 50);
indexes = repmat(row, 500, 1);
colors = jet(10);
colors = colors(randperm(10), :);
imageData = colors(indexes, :);
imageData = reshape(imageData, 500, 500, 3);
imageFile = fullfile(tempdir(), 'my-image.png');
imwrite(imageData, imageFile, 'png');

% view the image
imshow(imageFile)

%% Get repository configuration and credentials.

% cd to "project" folder so RemodeDataToolbox can locate JSON configuration
thisFolder = fileparts(which('rdtExamplePublishData'));
cd(thisFolder);

% enter credentials (test:test123) to complete the configuration
configuration = rdtCredentialsDialog('brainard-archiva');

%% Publish the image as an artifact.

% each artifact is located at a remote path
remotePath = 'project-demo';

% each artifact must have an artifactId, which is like a file name
artifactId = 'demo-image';

% each artifact must have a version, the default is version '1'
version = '42';

% supply the configuration, which now contains publishing credentials
artifact = rdtPublishArtifact(configuration, ...
    imageFile, ...
    remotePath, ...
    'artifactId', artifactId, ...
    'version', version);

%% See metadata about the new artifact!
disp(artifact)

%% Visit the new artifact on the web!

% From the directory listing, click on png file and check that the image in
% the brwoser matches the image in the Matlab figure.
rdtOpenBrowser(artifact);
