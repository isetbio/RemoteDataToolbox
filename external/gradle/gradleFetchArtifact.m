function [filePath, pomPath] = gradleFetchArtifact(repository, username, password, group, id, version, extension, varargin)
%% Use Gradle to fetch an artifact from a Maven repository.
%
% filePath = gradleFetchArtifact(repository, username, password, group, id, version, extension)
% fetches an artifact from the given repository url, with the given
% credentials and artifact coordinates.
%
% filePath = gradleFetchArtifact( ... 'refreshCached', refreshCached) obeys
% the optional refreshCached flag.  If refreshCached is true, refreshes the
% local cache for the fetched artifact.
%
% filePath = gradleFetchArtifact( ... 'cacheFolder', cacheFolder) uses the
% optional cacheFolder for the local artifact cache.
%
% filePath = gradleFetchArtifact( ... 'verbose', verbose) obeys the
% optional vebose flag.  If verbose is true, prints additional details to
% the command window.
%
% Returns the local file path to the fetched, cached file.  Also returns
% the path to the "pom" file, which is Xml metadata about the fetched file.
%
% See also gradlePublishArtifact
%
% filePath = gradleFetchArtifact(repository, username, password, group, id, version, extension, varargin)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('repository', @ischar);
parser.addRequired('username', @ischar);
parser.addRequired('password', @ischar);
parser.addRequired('group', @ischar);
parser.addRequired('id', @ischar);
parser.addRequired('version', @ischar);
parser.addRequired('extension', @ischar);
parser.addParameter('refreshCached', false, @islogical);
parser.addParameter('cacheFolder', '', @ischar);
parser.addParameter('verbose', false, @islogical);
parser.parse(repository, username, password, group, id, version, extension, varargin{:});
repository = parser.Results.repository;
username = parser.Results.username;
password = parser.Results.password;
group = parser.Results.group;
id = parser.Results.id;
version = parser.Results.version;
extension = parser.Results.extension;
refreshCached = parser.Results.refreshCached;
cacheFolder = parser.Results.cacheFolder;
verbose = parser.Results.verbose;

filePath = '';
pomPath = '';

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

if verbose
    disp(command);
end

[status, result] = system(command);
if 0 ~= status
    error('FetchArtifact:BadStatus', 'error status %d (%s)', status, result)
end

result

%% Scrape out the fetched files.
fileMatches = regexp(result, 'FETCHED "([^"]*)"', 'tokens');

% assume artifact comes before pom, the order specified in fetch.gradle.
if numel(fileMatches) > 0
    filePath = fileMatches{1}{1};
end

if numel(fileMatches) > 1
    pomPath = fileMatches{2}{1};
end
