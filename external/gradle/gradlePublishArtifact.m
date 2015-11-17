%% Proof of concept for publishing an artifact via Gradle.
%   @param repository
%   @param username
%   @param password
%   @param group
%   @param id
%   @param version
%   @param file
%
%	[filePath, extension] = gradlePublishArtifact(repository, username, password, group, id, version, file)
function [filePath, extension] = gradlePublishArtifact(repository, username, password, group, id, version, file)

filePath = '';

[inputPath, inputBase, inputExtension] = fileparts(file);
extension = inputExtension(inputExtension ~= '.');

%% Pass args to Gradle via enviromnent variables.
setenv('REPOSITORY', repository);
setenv('USERNAME', username);
setenv('PASSWORD', password);
setenv('GROUP', group);
setenv('ID', id);
setenv('VERSION', version);
setenv('EXTENSION', extension);
setenv('FILE', file);

%% Locate the gradle wrapper.
thisScript = mfilename('fullpath');
[thisPath, thisName, thisExt] = fileparts(thisScript);
gradlew = fullfile(thisPath, 'gradlew');
publishDotGradle = fullfile(thisPath, 'publish.gradle');

%% Invoke Gradle to publish the artifact.
dylibPath = 'DYLD_LIBRARY_PATH=""';
command = sprintf('%s %s --daemon -b %s publish', dylibPath, gradlew, publishDotGradle);
disp(command);
[status, result] = system(command);

if 0 ~= status
    error('PublishArtifact:BadStatus', 'error status %d (%s)', status, result)
end

%% Don't leak enviroment variables (especially PASSWORD!)
setenv('REPOSITORY');
setenv('USERNAME');
setenv('PASSWORD');
setenv('GROUP');
setenv('ID');
setenv('VERSION');
setenv('EXTENSION');
setenv('FILE');

%% Fetch the file and report the path into the local cache.
filePath = gradleFetchArtifact(repository, username, password, group, id, version, extension, true);
