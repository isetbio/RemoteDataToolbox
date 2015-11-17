%% Proof of concept for publishing an artifact via Gradle.
%   @param repository
%   @param username
%   @param password
%   @param group
%   @param id
%   @param version
%   @param file
%   @param cacheFolder
%
%	[filePath, extension] = gradlePublishArtifact(repository, username, password, group, id, version, file, cacheFolder)
function [filePath, extension] = gradlePublishArtifact(repository, username, password, group, id, version, file, cacheFolder)

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
