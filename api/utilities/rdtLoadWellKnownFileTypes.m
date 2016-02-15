function data = rdtLoadWellKnownFileTypes(artifact)
%% Load well-known file types, otherwise return file name
%
% data = rdtLoadWellKnownFileTypes(artifact) 
%  loads data from the given fetched artifact, if the artifact.type is
%  well-known (mat, json, or image). 
% Otherwise, returns artifact.localPath as a string.
%
% @rdtLoadWellKnownFileTypes is suitable value for the "loadFunction"
% parameter which you may pass to functions like rdtReadArtifact() and
% rdtReadArtifacts().
%
% See also rdtReadArtifact rdtReadArtifacts
%
% data = rdtLoadWellKnownFileTypes(artifact)
%
% Copyright (c) 2016 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('artifact', @isstruct);
parser.parse(artifact);
artifact = parser.Results.artifact;

%% Load the file.
imageTypes = imreadExtensions();
switch artifact.type
    case 'mat'
        data = load(artifact.localPath);
    case 'json'
        data = loadjson(artifact.localPath);
    case imageTypes
        data = imread(artifact.localPath);
    otherwise
        % let caller load the file data
        data = artifact.localPath;
end

%% Ask Matlab for recognized image file extensions.
function imageTypes = imreadExtensions()
formats = imformats();
imageTypes = cat(2, formats.ext);
