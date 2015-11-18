%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Fetch an artifact from a remote repository an read it into Matlab.
%   @param configuration RemoteDataToolbox configuration info
%   @param remotePath remote path to the artifact (required)
%   @param artifactId string id of the artifact itself (required)
%   @param version string artifact version (defaults to latest)
%   @param type string file type of the artifact (defaults to 'mat')
%
% @details
% Fetches an artifact from a remote respository, caches it in the local
% file system, and loads the artifact into a Matlab variable.  @a
% configuration.repositoryUrl should point at the repository root.
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
% remotePath, artifactId, server url, and local file path.  See
% rdtArtifact().
%
% @details
% If the fetch fails or the requested artifact doesn't exist, returns [].
%
% @details
% Usage:
%   [data, artifact] = rdtReadArtifact(configuration, remotePath, artifactId, varargin)
%
% @ingroup artifacts
function [data, artifact] = rdtReadArtifact(configuration, remotePath, artifactId, varargin)

parser = rdtInputParser();
parser.addRequired('configuration');
parser.addRequired('remotePath', @ischar);
parser.addRequired('artifactId', @ischar);
parser.addParameter('version', '+', @ischar);
parser.addParameter('type', 'mat', @ischar);
parser.parse(configuration, remotePath, artifactId, varargin{:});
configuration = rdtConfiguration(parser.Results.configuration);
remotePath = parser.Results.remotePath;
artifactId = parser.Results.artifactId;
version = parser.Results.version;
type = parser.Results.type;

data = [];
artifact = [];

%% Fetch the artifact.
localPath = gradleFetchArtifact(configuration.repositoryUrl, ...
    configuration.username, ...
    configuration.password, ...
    remotePath, ...
    artifactId, ...
    version, ...
    type, ...
    configuration.cacheFolder);

if isempty(localPath)
    return;
end

%% Build an artifact struct for the fetched artifact.
remoteUrl = [configuration.repositoryUrl '/' remotePath '/' artifactId '/' version];
artifact = rdtArtifact( ...
    'remotePath', remotePath, ...
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
