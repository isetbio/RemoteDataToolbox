function [filePath, extension] = gradlePublishArtifact(repository, username, password, group, id, version, file, cacheFolder)
%% Use Gradle to publish an artifact to a Maven repository.
%
% [filePath, extension] = gradlePublishArtifact(repository, username, password, group, id, version, file)
% publishes the given file as an artifact to the given repository url, with
% the given credentials and artifact coordinates.
%
% filePath = gradleFetchArtifact( ... cacheFolder) uses the optional
% cacheFolder for the local artifact cache.
%
% Returns the local file path to the published, cached file.  Also returns
% the published artifact type, which is the same as the given file
% extendsion.
%
% See also gradleFetchArtifact
%
% Copyright (c) 2015 RemoteDataToolbox Team

filePath = '';

if nargin < 8 || isempty(cacheFolder)
    cacheFolder = '';
end

[inputPath, inputBase, inputExtension] = fileparts(file);
extension = inputExtension(inputExtension ~= '.');

%% Pass args to Gradle via enviromnent variables.
%% -D Define system properties.
systemProps = [ ...
    '-DREPOSITORY=' repository ' ' ...
    '-DUSERNAME=' username ' ' ...
    '-DPASSWORD=' password ' ' ...
    '-DGROUP=' group ' ' ...
    '-DID=' id ' ' ...
    '-DVERSION=' version ' ' ...
    '-DEXTENSION=' extension ' ' ...
    '-DFILE=' file ' '];

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

disp(command);
[status, result] = system(command);
if 0 ~= status
    error('PublishArtifact:BadStatus', 'error status %d (%s)', status, result)
end

%% Fetch the file and report the path into the local cache.
filePath = gradleFetchArtifact(repository, username, password, group, id, version, extension, true);
