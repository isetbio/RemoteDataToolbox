function [filePath, pomPath, downloads] = gradleFetchArtifact(repository, username, password, group, id, version, extension, varargin)
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
% Also returns a cell array of urls to files that had to be downloaded from
% the server (i.e. were not cached locally), if any.
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
downloads = {};

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

% Windows returns backslashes in paths, but these get escaped. Forward
% slashes do not get escaped.
commandEnv = 'DYLD_LIBRARY_PATH='''' TERM=${TERM:-dumb}';
command = sprintf('%s %s --daemon %s %s %s -b %s fetchIt', ...
    commandEnv, ...
    strrep(gradlew,'\','/'), ...
    refresh, ...
    systemProps, ...
    cache, ...
    strrep(fetchDotGradle,'\','/'));

if verbose
    disp(command);
end

% If on Windows, check for bash.
if ispc
    [status, result] = system('where bash');
    if 0 ~= status
        msg = ['error status %d %s' ...
            'To obtain bash for windows, you may download Cygwin from https://cygwin.com/install.html. ' ...
            'Alternatively, you may download Git which bundles bash from https://git-scm.com/download/win. ' ...
            'Either way, make sure you add the path to bash to your windows environment path, then restart Matlab.' 
            ];
        error('FetchArtifact:BadStatus', msg, status, result)
    end
end

% We must explicitly call bash when on Windows platforms. On Mac/Linux, the
% use of bash is implied through the system call.
command = sprintf('%s "%s"', 'bash -c', command);
[status, result] = system(command);
if 0 ~= status
    error('FetchArtifact:BadStatus', 'error status %d (%s)', status, result)
end

%% Scrape printed-out results.

% what was downloaded from the server?
% Download http://52.32.77.154/repository/demo-repository/classifiers/test/1/test-1.pom
downloads = scrapeLinesWithPrefix(result, 'Download ');

% what was successfully fetched?
% FETCHED fetchPom /home/ben/.gradle/caches/modules-2/files-2.1/classifiers/test/1/4dc69fb8460ab022d05618308858ecc5659de678/test-1.pom
pom = scrapeLinesWithPrefix(result, 'FETCHED fetchPom ');
withClassifier = scrapeLinesWithPrefix(result, 'FETCHED fetchWithClassifier ');
withoutClassifier = scrapeLinesWithPrefix(result, 'FETCHED fetchWithoutClassifier ');

% what couldn't be fetched?
% ERROR fetchWithoutClassifier Could not resolve all dependencies for configuration ':fetchWithoutClassifier'.
errors = scrapeLinesWithPrefix(result, 'ERROR ');

%% Choose return values.
if ~isempty(pom)
    pomPath = pom{1};
end

if ~isempty(withClassifier)
    filePath = withClassifier{1};
    return;
elseif ~isempty(withoutClassifier)
    filePath = withoutClassifier{1};
    return;
end

%% Could not find the artifact!
error('gradleFetchArtifact:noArtifact', '%s\n', errors{:});

%% Scrape one or more lines of text from the input text by prefix matching.
function lines = scrapeLinesWithPrefix(text, prefix)
tokens = regexp(text, [prefix '([^\r\n]*)[\r\n]'], 'tokens');
nLines = numel(tokens);
lines = cell(1, nLines);
for ii = 1:nLines
    lines{ii} = tokens{ii}{1};
end
