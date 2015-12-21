function url = rdtOpenBrowser(configOrArtifact, varargin)
%% Open a server or repository url in a web browser.
%
%   url = rdtOpenBrowser(configuration) 
%
% Takes the given render toolbox config struct and opens
% configuration.serverUrl in a web browser.  If configuration.serverUrl is
% missing, opens configuration.repositoryUrl instead.
%
% url = rdtOpenBrowser(artifact) takes the given render toolbox artifact
% struct and opens artifact.url in a web browser.
%
% url = rdtOpenBrowser(anyStruct, whichUrl) takes any given struct and
% opens anyStruct.whichUrl in a web browser.
%
% Returns the url that was opened in the web browser.
%
% See also rdtConfiguration, rdtArtifact
%
% url = rdtOpenBrowser(configOrArtifact, varargin)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('configOrArtifact', @isstruct);
parser.addOptional('whichUrl', '', @ischar);
parser.parse(configOrArtifact, varargin{:});
configOrArtifact = rdtConfiguration(parser.Results.configOrArtifact);
whichUrl = parser.Results.whichUrl;

url = '';

if ~isempty(whichUrl) && isfield(configOrArtifact, whichUrl)
    % custom field as url
    url = configOrArtifact.(whichUrl);
    
elseif isfield(configOrArtifact, 'url')
    % looks like an artifact
    url = configOrArtifact.url;
    
elseif isfield(configOrArtifact, 'serverUrl')
    % looks like a config struct
    url = configOrArtifact.serverUrl;
    
elseif isfield(configOrArtifact, 'repositoryUrl')
    % looks like a config struct
    url = configOrArtifact.repositoryUrl;
end

if isempty(url)
    warning('rdtOpenBrowser:noUrlFound', ...
        'Found no url to open (whichUrl=<%s>', whichUrl);
end

% open url in system browser, not Matlab browser
web(url, '-browser')
