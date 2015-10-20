%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Open a repository url in a web browser.
%   @param configOrArtifact RemoteDataToolbox config. or artifact struct
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
% If @configOrArtifact is omitted, uses the default confuguration struct
% returned from rdtConfiguration().
%
% @details
% Returns the url that was passed to the web browser for browsing.
%
% @details
% Usage:
%   url = rdtOpenBrowser(configOrArtifact, whichUrl)
%
% @ingroup utilities
function url = rdtOpenBrowser(configOrArtifact, whichUrl)

if nargin < 1 || isempty(configOrArtifact)
    configOrArtifact = rdtConfiguration();
else
    configOrArtifact = rdtConfiguration(configOrArtifact);
end

if nargin < 2 || isempty(whichUrl)
    whichUrl = '';
end

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
