%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Initialize a struct with RemoteDataToolbox configuration
%   @param varargin a file path, a struct, or multiple name-value pairs
%
% @details
% Initializes a struct containing RemoteDataToolbox configuration.
% Configuration values may be merged from multiples sources.  In increasing
% order of pereference these sources are:
%   - default values declared in this function
%   - project-specific values declared in a remote-data-toolbox.json file
%   located in the given @a varargin folder (default is pwd()) or a parent
%   folder
%   - values declared in the given @a varargin struct or name-value pairs
%
% @details
% @a varargin may have one of three forms:
%   - a single string file path to search for remote-data-toolbox.json
%   - a single struct containing multiple field-value pairs of
%   configuration
%   - multiple name-value pairs of configuration
%
% @details
% Returns a struct of RemoteDataToolbox configuration.
%
% @details
% Usage:
%   configuration = rdtConfiguration(varargin)
%
% @ingroup utilities
function configuration = rdtConfiguration(varargin)

%% What did the user pass in?
configArgs = struct();
configFolder = pwd();
if 1 == nargin
    argin = varargin{1};
    if isstruct(argin)
        configArgs = argin;
    elseif ischar(argin)
        configFolder = argin;
    end
    
elseif 1 < nargin && 0 == mod(nargin, 2)
    % passed in name-value paris
    configArgs = struct(varargin{:});
end

%% Start with default configuration.
configuration = getDefaultConfiguration();

%% Merge with project-specific configuration from file.
jsonConfigFile = 'remote-data-toolbox.json';
jsonConfigPath = rdtSearchParentFolders(jsonConfigFile, configFolder);
if ~isempty(jsonConfigPath)
    jsonConfiguration = rdtFromJson(jsonConfigPath);
    configuration = rdtMergeStructs(configuration, jsonConfiguration);
end

%% Merge with configuration passed in as parameters.
configuration = rdtMergeStructs(configuration, configArgs);

%% Source of truth for required fields and default values.
function configuration = getDefaultConfiguration()
configuration = struct( ...
    'serverUrl', '', ...
    'repositoryName', '', ...
    'username', 'guest', ...
    'password', '', ...
    'requestMediaType', 'application/json', ...
    'acceptMediaType', 'application/json');
