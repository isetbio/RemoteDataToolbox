function [data, artifact, downloads] = rdtReadArtifact(configuration, remotePath, artifactId, varargin)
%% Fetch an artifact from a remote repository an read it into Matlab.
%
% [data, artifact] = rdtReadArtifact(configuration, remotePath, artifactId)
% fetches an artifact from a remote respository, under the given remotePath
% and with the given artifactId.  Loads the artifact data into a Matlab
% variable.  configuration.repositoryUrl must point at the repository root.
%
% [data, artifact] = rdtReadArtifact( ... 'version', version) fetches an
% artifact with the given version instead of the default, which is the
% latest version available.
%
% [data, artifact] = rdtReadArtifact( ... 'type', type) fetches an
% artifact with the given type instead of the default 'mat'.
%
% Note: you must supply the full remotePath where the artifact is located.
% For example, to read "/path/to/file/foo.txt", you would have to supply
% the full "/path/to/file".  Supplying "/path" would not be enough.
%
% Returns a Matlab variable containing the artifact data.  The class of the
% returned variable depends on the artifact type:
%   - 'mat': struct of variables from the built-in load()
%   - 'json': struct or arry of JSON data from loadjson()
%   - image (see imformat()): array of image data from built-in imread()
%   - default: char array from fread(..., '*char')
%
% Also returns a struct of metadata about the artifact.  Also returns a
% cell array of urls for artifacts that were downloaded from the remote
% server (i.e. not already in the local cache).
%
% See also rdtArtifact rdtReadArtifacts imformat imread
%
% [data, artifact, downloads] = rdtReadArtifact(configuration, remotePath, artifactId, varargin)
%
% Copyright (c) 2015 RemoteDataToolbox Team

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
try
[localPath, pomPath, downloads] = gradleFetchArtifact(configuration.repositoryUrl, ...
    configuration.username, ...
    configuration.password, ...
    rdtPathSlashesToDots(remotePath), ...
    artifactId, ...
    version, ...
    type, ...
    'cacheFolder', configuration.cacheFolder, ...
    'verbose', logical(configuration.verbosity));
catch ex
    fprintf('Could not find artifactId <%s> of type <%s> at remotePath <%s>\n', ...
        artifactId, type, remotePath);
    fprintf('Suggestion: specify the full remotePath, not just a parent path:\n');
    fprintf('  rdtReadArtifact( ... ''remotePath'', ''/foo/bar/baz'')\n');
    fprintf('  rather than\n');
    fprintf('  rdtReadArtifact( ... ''remotePath'', ''/foo'')\n');
    fprintf('Suggestion: specify the artifact file type:\n');
    fprintf('  rdtReadArtifact( ... ''type'', ''jpg'')\n');
    fprintf('  rdtReadArtifact( ... ''type'', ''tiff'')\n');
    fprintf('  rdtReadArtifact( ... ''type'', ''gz'')\n');
    fprintf('  etc...\n');
    rethrow(ex);
end

if isempty(localPath)
    return;
end

%% Read more metadata from the artifact pom.
fid = fopen(pomPath, 'r');
if fid < 0
    description = '';
    name = '';
else
    xmlString = fread(fid, '*char')';
    description = rdtScrapeXml(xmlString, 'description', '');
    name = rdtScrapeXml(xmlString, 'name', '');
    fclose(fid);
end

%% Build an artifact struct for the fetched artifact.
remoteUrl = rdtBuildArtifactUrl(configuration.repositoryUrl, remotePath, artifactId, version);
artifact = rdtArtifact( ...
    'remotePath', remotePath, ...
    'artifactId', artifactId, ...
    'version', version, ...
    'type', type, ...
    'localPath', localPath, ...
    'url', remoteUrl, ...
    'description', description, ...
    'name', name);

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
