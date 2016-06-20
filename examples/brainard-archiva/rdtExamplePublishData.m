%% This is a tutorial for the Remote Data Toolbox object-oriented API.
%
% This script shows how you might generate some data as part of a project
% and publish that data as an artifact to the project's remote data
% repository.
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
% See also rdtExampleReadData, rdtPublishArtifacts
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
imageFile = fullfile(tempdir(), 'demo-image.png');
imwrite(imageData, imageFile, 'png');

% view the image
imshow(imageFile)

%% Create a client object with project configuration and credentials.
client = RdtClient('brainard-archiva');
client.credentialsDialog();

%% Publish the image as an artifact.

% change to the "remote path" where we want to publish the artifact
client.crp('/project-demo');

% each artifact must have a version, the default is version '1'
version = '40';

% supply the configuration, which now contains publishing credentials
artifact = client.publishArtifact(imageFile, ...
    'version', version, ...
    'description', 'This is a test image with random-colored vertical stripes.', ...
    'name', 'Dr. Stripes');

%% See metadata about the new artifact!
disp(artifact)

%% Visit the new artifact on the web!

% should see the artifact image in the browser
client.openBrowser(artifact);
