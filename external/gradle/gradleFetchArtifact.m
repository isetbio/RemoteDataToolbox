%% Proof of concept for fetching an artifact via Gradle.
%   @param repository
%   @param username
%   @param password
%   @param group
%   @param id
%   @param version
%   @param extension
%   @param refreshCached
%
%   filePath = gradleFetchArtifact(repository, username, password, group, id, version, extension, refreshCached)
function filePath = gradleFetchArtifact(repository, username, password, group, id, version, extension, refreshCached)

filePath = '';

if nargin < 8 || isempty(refreshCached)
    refreshCached = false;
end

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
if refreshCached
    refresh = '--refresh-dependencies';
else
    refresh = '';
end

dylibPath = 'DYLD_LIBRARY_PATH=""';
command = sprintf('%s %s --daemon %s -b %s fetchIt', dylibPath, gradlew, refresh, fetchDotGradle);
disp(command);
[status, result] = system(command);

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