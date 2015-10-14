%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Open a repository url in a web browser.
%   @param whichUrl name of the url to open, 'serverUrl' or 'repositoryUrl'
%   @param configuration optional RemoteDataToolbox configuration struct
%
% @details
% Opens a url in a web browser for viewing.  If @a configuration is
% provided, opens a url from the given @a configuration.  Otherwise, uses
% the configuration returned from rdtConfiguration().
%
% @details
% By default, opens @configuration.serverUrl, which would be suitable for
% browsing and searching with a web application like Archiva.  If @a
% whichUrl is equal to 'repositoryUrl', instead opens a "raw" HTML table of
% contents for the Maven repository.
%
% @details
% Usage:
%
% @ingroup utilities
function rdtOpenBrowser(whichUrl, configuration)

if nargin < 1 || isempty(whichUrl)
    whichUrl = 'serverUrl';
end

if nargin < 2 || isempty(configuration)
    configuration = rdtConfiguration();
else
    configuration = rdtConfiguration(configuration);
end

web(configuration.(whichUrl), '-browser')
