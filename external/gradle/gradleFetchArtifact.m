function filePath = gradleFetchArtifact(repository, username, password, group, id, version, extension, refreshCached, cacheFolder)
%% Use Gradle to fetch an artifact from a Maven repository.
%
% filePath = gradleFetchArtifact(repository, username, password, group, id, version, extension)
% fetches an artifact from the given repository url, with the given
% credentials and artifact coordinates.
%
% filePath = gradleFetchArtifact( ... refreshCached ...) obeys the optional
% refreshCached flag.  If refreshCached is true, refreshes the local cache
% for the fetched artifact.
%
% filePath = gradleFetchArtifact( ... cacheFolder) uses the optional
% cacheFolder for the local artifact cache.
%
% Returns the local file path to the fetched, cached file.
%
% See also gradlePublishArtifact
%
% Copyright (c) 2015 RemoteDataToolbox Team

filePath = '';

if nargin < 8 || isempty(refreshCached)
    refreshCached = false;
end

if nargin < 9 || isempty(cacheFolder)
    cacheFolder = '';
end

%% -D Define system properties.
systemProps = [ ...
    '-DREPOSITORY=' repository ' ' ...
    '-DUSERNAME=' username ' ' ...
    '-DPASSWORD=' password ' ' ...
    '-DGROUP=' group ' ' ...
    '-DID=' id ' ' ...
    '-DVERSION=' version ' ' ...
    '-DEXTENSION=' extension ' '];

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

if ~isempty(cacheFolder)
    cache = [ ...
        '--project-cache-dir "' cacheFolder '" ' ...
        '--gradle-user-home "' cacheFolder '" '];
else
    cache = '';
end

dylibPath = 'DYLD_LIBRARY_PATH=""';
command = sprintf('%s %s --daemon %s %s %s -b %s fetchIt', ...
    dylibPath, ...
    gradlew, ...
    refresh, ...
    systemProps, ...
    cache, ...
    fetchDotGradle);

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
