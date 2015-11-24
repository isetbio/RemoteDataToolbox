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

% change to the "remote path" where we expect to find our artifact
client.crp('project-demo');

% fetch our artifact
[data, artifact] = client.readArtifact('demo-image', 'type', 'png');

%% See metadata about the artifact we just fetched.
disp(artifact)

%% Display the artifact data as an image.
imshow(data);
