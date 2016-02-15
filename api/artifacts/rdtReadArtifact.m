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
% [data, artifact] = rdtReadArtifact( ... 'destinationFolder', destinationFolder)
% copies the fetched artifact from the local artifact cache to the given
% destinationFolder.  In this case artifact.localPath will point to the
% destinationFolder.  The name of the copied artifact will have the
% form <artifactId>.<type>.  This name may differ from the file name used
% on the remote server or within the local cache.
%
% [data, artifact] = rdtReadArtifact( ... 'loadFunction', loadFunction)
% uses the given loadFunction to load the fetched artifact into memory.
% The load function must have the following form:
%   function data = myLoadFunction(artifactStruct)
% The data returned from this funciton will be whatever was returned from
% myLoadFunction.  The default is @rdtLoadWellKnownFileTypes.
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
parser.addParameter('destinationFolder', '', @ischar);
parser.addParameter('loadFunction', @rdtLoadWellKnownFileTypes, @(f) isa(f, 'function_handle'));
parser.parse(configuration, remotePath, artifactId, varargin{:});
configuration = rdtConfiguration(parser.Results.configuration);
remotePath = parser.Results.remotePath;
artifactId = parser.Results.artifactId;
version = parser.Results.version;
type = parser.Results.type;
destinationFolder = parser.Results.destinationFolder;
loadFunction = parser.Results.loadFunction;

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
    version = rdtScrapeXml(xmlString, 'version', '');
    fclose(fid);
end

%% Copy to a destination folder?
if ~isempty(destinationFolder)
    if 7 ~= exist(destinationFolder, 'dir')
        rdtPrintf(configuration.verbosity, ...
            'Create destination folder "%s"\n', destinationFolder);
        
        mkdir(destinationFolder);
    end
    
    % make a simple file name which "undoes" a Maven naming convention
    %   this is important eg when file name contains a double extension
    %   foo.nii.gz (original) -> foo.nii-1-gz.gz (Maven) -> foo.nii.gz (simple)
    destinationPath = fullfile(destinationFolder, [artifactId '.' type]);
    [success, message] = copyfile(localPath, destinationPath, 'f');
    if success
        rdtPrintf(configuration.verbosity, ...
            'Copy artifact to "%s"\n', destinationPath);
        localPath = destinationPath;
    else
        rdtPrintf(configuration.verbosity, ...
            'Could not copy artifact to "%s":\n  %s\n', ...
            destinationPath, message);
    end
end

%% Build an artifact struct for the fetched artifact.
remoteUrl = rdtBuildArtifactUrl(configuration.repositoryUrl, remotePath, artifactId, version, localPath);
artifact = rdtArtifact( ...
    'remotePath', remotePath, ...
    'artifactId', artifactId, ...
    'version', version, ...
    'type', type, ...
    'localPath', localPath, ...
    'url', remoteUrl, ...
    'description', description, ...
    'name', name);

%% Load the artifact data into memory.
data = feval(loadFunction, artifact);

if ischar(data) && 2 == exist(data, 'file')
    rdtPrintf(configuration.verbosity, ...
        'Artifact data is a file name "%s"\n', data);
end
