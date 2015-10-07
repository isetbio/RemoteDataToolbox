%% Proof of concept showing off "gradle wrapper" ease of use (I hope).
%
% You should be able to:
%   - Add RemoteDataToolbox to your Matlab path, including this new folder.
%   - Run GradleDemo (this script).
%   - See that an artifact was fetched from a Maven Repository.
%   - Load the artifact (some text) in Matlab and play with it.
%
% The file fetched in this example is a Maven "pom" file, which is XML
% describing an artifact.  The artifact is on a public server called Maven
% Central.
%
% See what we're fetching in your browser:
%   https://repo1.maven.org/maven2/jython/jython/2.1/
%
% For fun, try changing the extension below to 'jar'.  This will fetch the
% actual Java library, which will display as gibbersih.
%
% We will want to fetch Matlab mat files, which we will pass to the load()
% command.  It would be nice to load() a mat file in this demo, but I don't
% know of any public Maven repositories with mat files in them (yet...).
%
% BSH 23 September 2015

clear;

%% "Maven Central" repository is always "up" and readable by the public.
repository = 'https://repo1.maven.org/maven2/';
username = '';
password = '';

%% Choose to fetch some text metadata associated with an artifact.
group = 'jython';
id = 'jython';
version = '2.1';
extension = 'pom';
%extension = 'jar';

%% Fetch it!
filePath = FetchArtifact( ...
    repository, ...
    username, ...
    password, ...
    group, ...
    id, ...
    version, ...
    extension);

%% Look at what we got!
disp(' ')
disp('Got file in local cache:')
disp(filePath)

% load file text
fid = fopen(filePath);
data = fread(fid);
fclose(fid);

% display as char array
disp(' ')
dataChars = char(data');
disp('File contains:')
disp(dataChars)
