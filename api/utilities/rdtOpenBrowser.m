%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Open a repository url in a web browser.
%   @param configOrArtifact RemoteDataToolbox config or artifact struct
%   @param whichUrl optional field name to open as a url
%
% @details
% Opens a url in a web browser for viewing.  If @a configOrArtifact is a
% Remote Data Toolbox artifact struct opens @a configOrArtifact.url.  If @a
% configOrArtifact is a RemoteDataToolbox configuration struct, opens @a
% configOrArtifact.serverUrl or @a configOrArtifact.repositoryUrl.
%
% @details
% If @a whichUrl is provided, opens @a configOrArtifact.(whichUrl) instead
% of the default.
%
% @details
% Returns the url that was passed to the web browser for browsing.
%
% @details
% Usage:
%   url = rdtOpenBrowser(configOrArtifact, whichUrl)
%
% @ingroup utilities
function url = rdtOpenBrowser(configOrArtifact, varargin)
%% Open a repository url in a web browser.
%
% url = rdtOpenBrowser(configuration) takes the given render toolbox config
% struct and opens configuration.serverUrl in a web browser.  If
% configuration.serverUrl is missing, opens configuration.repositoryUrl
% instead.
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
