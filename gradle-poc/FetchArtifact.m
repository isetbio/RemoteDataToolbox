%% Proof of concept for fetching an artifact via Gradle.
%   @param repository
%   @param username
%   @param password
%   @param group
%   @param id
%   @param version
%   @param extension
function filePath = FetchArtifact(repository, username, password, group, id, version, extension)

filePath = '';

%% Pass args to Gradle via enviromnent variables.
setenv('REPOSITORY', repository);
setenv('USERNAME', username);
setenv('PASSWORD', password);
setenv('GROUP', group);
setenv('ID', id);
setenv('VERSION', version);
setenv('EXTENSION', extension);

%% Locate the gradle wrapper.
thisScript = mfilename('fullpath');
[thisPath, thisName, thisExt] = fileparts(thisScript);
gradlew = fullfile(thisPath, 'gradlew');
fetchDotGradle = fullfile(thisPath, 'fetch.gradle');

%% Invoke Gradle.
command = sprintf('%s -b %s fetchIt', gradlew, fetchDotGradle);
disp(command);

% temporarily clear the library path, which breaks gradlew
DYLD_LIBRARY_PATH = getenv('DYLD_LIBRARY_PATH');
setenv('DYLD_LIBRARY_PATH');

[status, result] = system(command);

% restore the library path that Matlab wants
setenv('DYLD_LIBRARY_PATH', DYLD_LIBRARY_PATH);

if 0 ~= status
    error('FetchArtifact:BadStatus', 'error status %d (%s)', status, result)
end

%% Scrape out the fetched file.
lineEnds = strfind(result, char(10));
fetched = strfind(result, 'FETCHED');
nextLines = lineEnds(lineEnds > fetched);
pathStart = fetched + 8;
pathEnd = nextLines(1);
filePath = result(pathStart:pathEnd-1);

%% Don't leak enviroment variables (especially PASSWORD!)
setenv('REPOSITORY');
setenv('USERNAME');
setenv('PASSWORD');
setenv('GROUP');
setenv('ID');
setenv('VERSION');
setenv('EXTENSION');
