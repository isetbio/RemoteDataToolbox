function [filePath, pomPath, extension] = gradlePublishArtifact(repository, username, password, group, id, version, file, varargin)
%% Use Gradle to publish an artifact to a Maven repository.
%
% [filePath, extension] = gradlePublishArtifact(repository, username, password, group, id, version, file)
% publishes the given file as an artifact to the given repository url, with
% the given credentials and artifact coordinates.
%
% filePath = gradlePublishArtifact( ... 'description', description) adds
% the given description to the artifact metadata.  The default is no
% description.
%
% filePath = gradlePublishArtifact( ... 'name', name) adds the given
% name to the artifact metadata.  The default is no name.
%
% filePath = gradlePublishArtifact( ... 'cacheFolder', cacheFolder) uses
% the optional cacheFolder for the local artifact cache.
%
% filePath = gradlePublishArtifact( ... 'verbose', verbose) obeys the
% optional vebose flag.  If verbose is true, prints additional details to
% the command window.
%
% Returns the local file path to the published, cached file.  Also returns
% the path to the "pom" file, which is Xml with artifact metadata.  Also
% returns  the published artifact type, which is the same as the given file
% extendsion.
%
% See also gradleFetchArtifact
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('repository', @ischar);
parser.addRequired('username', @ischar);
parser.addRequired('password', @ischar);
parser.addRequired('group', @ischar);
parser.addRequired('id', @ischar);
parser.addRequired('version', @ischar);
parser.addRequired('file', @ischar);
parser.addParameter('description', '', @ischar);
parser.addParameter('name', '', @ischar);
parser.addParameter('cacheFolder', '', @ischar);
parser.addParameter('verbose', false, @islogical);
parser.parse(repository, username, password, group, id, version, file, varargin{:});
repository = parser.Results.repository;
username = parser.Results.username;
password = parser.Results.password;
group = parser.Results.group;
id = parser.Results.id;
version = parser.Results.version;
file = parser.Results.file;
description = parser.Results.description;
name = parser.Results.name;
cacheFolder = parser.Results.cacheFolder;
verbose = parser.Results.verbose;

filePath = '';
pomPath = '';

[inputPath, inputBase, inputExtension] = fileparts(file);
extension = inputExtension(inputExtension ~= '.');

%% Pass args to Gradle via enviromnent variables.
%% -D Define system properties.
systemProps = [ ...
    '-DREPOSITORY="' repository '" ' ...
    '-DUSERNAME="' username '" ' ...
    '-DPASSWORD="' password '" ' ...
    '-DGROUP="' group '" ' ...
    '-DID="' id '" ' ...
    '-DVERSION="' version '" ' ...
    '-DEXTENSION="' extension '" ' ...
    '-DDESCRIPTION="' description '" ' ...
    '-DNAME="' name '" ' ...
    '-DFILE="' file '" '];

%% Locate the gradle wrapper.
thisScript = mfilename('fullpath');
[thisPath, thisName, thisExt] = fileparts(thisScript);
gradlew = fullfile(thisPath, 'gradlew');
publishDotGradle = fullfile(thisPath, 'publish.gradle');

%% Invoke Gradle to publish the artifact.
if ~isempty(cacheFolder)
    cache = [ ...
        '--project-cache-dir "' cacheFolder '" ' ...
        '--gradle-user-home "' cacheFolder '" '];
else
    cache = '';
end

dylibPath = 'DYLD_LIBRARY_PATH=""';
command = sprintf('%s %s --daemon %s %s -b %s publish', ...
    dylibPath, ...
    gradlew, ...
    systemProps, ...
    cache, ...
    publishDotGradle);

if verbose
    disp(command);
end

[status, result] = system(command);
if 0 ~= status
    error('PublishArtifact:BadStatus', 'error status %d (%s)', status, result)
end

%% Fetch the file and report the path into the local cache.
[filePath, pomPath] = gradleFetchArtifact(repository, ...
    username, ...
    password, ...
    group, ...
    id, ...
    version, ...
    extension, ...
    'refreshCached', true, ...
    'cacheFolder', cacheFolder, ...
    'verose', verbose);
