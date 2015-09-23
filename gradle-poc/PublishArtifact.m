%% Proof of concept for publishing an artifact via Gradle.
%   @param repository
%   @param username
%   @param password
%   @param group
%   @param id
%   @param version
%   @param file
function filePath = PublishArtifact(repository, username, password, group, id, version, file)

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

%% Invoke Gradle.
command = sprintf('%s -b %s publish', gradlew, publishDotGradle);
disp(command);

% temporarily clear the library path, which breaks gradlew
DYLD_LIBRARY_PATH = getenv('DYLD_LIBRARY_PATH');
setenv('DYLD_LIBRARY_PATH');

[status, result] = system(command);

% restore the library path that Matlab wants
setenv('DYLD_LIBRARY_PATH', DYLD_LIBRARY_PATH);

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
filePath = FetchArtifact(repository, username, password, group, id, version, extension);
