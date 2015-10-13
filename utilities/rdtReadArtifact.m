%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Fetch an artifact from a Maven repository an read it into Matlab.
%   @parap groupId string id of the artifact's group (required)
%   @parap artifactId string id of the artifact itself (required)
%   @parap version string artifact version (defaults to latest)
%   @parap type string file type of the artifact (defaults to 'mat')
%   @param configuration optional RemoteDataToolbox configuration struct
%
% @details
% Fetches an artifact from a Maven respository, caches it in the local file
% system, and loads the artifact into a Matlab variable.  If @a
% configuration is provided, queries the server at @a
% configuration.repository.  Otherwise, uses the configuration returned
% from rdtConfiguration().
%
% @details
% Returns a Matlab variable containing the artifact data.  The class of the
% returned variable depends on the given @a type:
%   - 'mat': struct of variables from the built-in load()
%   - 'json': struct or arry of JSON data from loadjson()
%   - image (see imformat()): array of image data from built-in imread()
%   - default: char array from fread(..., '*char')
%   .
%
% @details
% Also returns a struct of metadata about the artifact, including its
% groupId, artifactId, server url, and local file path.  See rdtArtifact().
%
% @details
% If the fetch fails or the requested artifact doesn't exist, returns [].
%
% @details
% Usage:
%   artifacts = rdtListGroups(configuration)
%
% @ingroup utilities
function [data, artifact] = rdtReadArtifact(groupId, artifactId, version, type, configuration)

data = [];
artifact = [];

if nargin < 3 || isempty(version)
    version = '+';
end

if nargin < 4 || isempty(type)
    type = 'mat';
end

if nargin < 5 || isempty(configuration)
    configuration = rdtConfiguration();
else
    configuration = rdtConfiguration(configuration);
end

%% Fetch the artifact.
localPath = gradleFetchArtifact(configuration.repositoryUrl, ...
    configuration.username, ...
    configuration.password, ...
    groupId, ...
    artifactId, ...
    version, ...
    type);

if isempty(localPath)
    return;
end

%% Build an artifact struct for the fetched artifact.
remoteUrl = [configuration.repositoryUrl '/' groupId '/' artifactId '/' version];
artifact = rdtArtifact( ...
    'groupId', groupId, ...
    'artifactId', artifactId, ...
    'version', version, ...
    'type', type, ...
    'localPath', localPath, ...
    'url', remoteUrl);

%% Load the artifact data.
imageTypes = imreadExtensions();
switch type
    case 'mat'
        data = load(localPath);
    case 'json'
        data = loadjson(localPath);
    case imageTypes
        data = imread(localPath);
    otherwise
        fid = fopen(localPath);
        data = fread(fid, '*char')';
        fclose(fid);
end

%% Ask Matlab for recognized image file extensions.
function imageTypes = imreadExtensions()
formats = imformats();
imageTypes = cat(2, formats.ext);
