%% This is a tutorial for the Remote Data Toolbox object-oriented API.
%
% This script shows how you might access some shared data which is part of
% a project.  The shared data would have been published already to the
% project's remote repository.
%
% This script uses a JSON file to configure a Remote Data Toolbox client
% object with things like the Url of the project's remote repository.  This
% simplifies various calls to the Remote Data Toolbox functions.
%
% This script does not require you to enter repository credentials because
% all we are doing is reading data that someone else published.  We can do
% this with the default "guest" account.
%
% Copyright (c) 2015 RemoteDataToolbox Team

clear;
clc;

%% Fetch an image from the repository.

% get a client configured for our repository
client = RdtClient('brainard-archiva');

% To read an artifact we must supply at least the artifactId, the
% remotePath where the artifact is located, and the type of the artifact.
% There are a few ways to do this:

% 1. Change the working remote path of our client object to match the
% artifact we want, and specify the "type" explicitly.
client.crp('/project-demo');
[data, artifact] = client.readArtifact('demo-image', ...
    'type', 'png');

% 2. Specify both the "remote path" and the "type" explicitly.
[data, artifact] = client.readArtifact('demo-image', ...
    'type', 'png', ...
    'remotePath', 'project-demo');

% 3. Obtain an artifact metadata strut from listArtifacts() or
% searchArtifacts() and pass it to readArtifacts()-with-an-s.
list = client.listArtifacts('remotePath', 'project-demo', ...
    'artifactId', 'demo-image', ...
    'type', 'png');
[dataCell, artifactCell] = client.readArtifacts(list);
data = dataCell{1};
artifact = artifactCell(1);

%% See metadata about the artifact we just fetched.
disp(artifact)

%% Display the artifact data as an image.
imshow(data);
