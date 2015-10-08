%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Initialize a struct with RemoteDataToolbox configuration
%   @param varargin a single struct, or multiple name-value pairs
%
% @details
% Initializes a struct containing RemoteDataToolbox configuration.
% Configuration values may be merged from multiples sources.  In increasing
% order of pereference these sources are:
%   - default values declared in this function
%   - project-specific values declared in a remote-data-toolbox.json file
%   located in the current folder or a parent folder
%   - values declared in the given @a varargin struct or name-value pairs
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

%% Start with default configuration.
configuration = getDefaultConfiguration();

%% Merge with project-specific configuration.
jsonConfigFile = 'remote-data-toolbox.json';
jsonConfigPath = rdtSearchParentFolders(jsonConfigFile, pwd());
if ~isempty(jsonConfigPath)
    jsonConfiguration = loadjson(jsonConfigPath);
    configuration = mergeStructs(configuration, jsonConfiguration);
end

%% Merge with configuration passed in as parameters.
if 1 == nargin
    % passed in a struct
    configuration = mergeStructs(configuration, varargin{1});
    
elseif 1 < nargin && 0 == mod(nargin, 2)
    % passed in name-value paris
    configuration = mergeStructs(configuration, struct(varargin{:}));
end

%% Source of truth for required fields and default values.
function configuration = getDefaultConfiguration()
configuration = struct( ...
    'repository', '', ...
    'username', 'guest', ...
    'password', '', ...
    'requestMediaType', 'application/json');

%% Smash fields of the second struct onto the first struct.
function target = mergeStructs(target, source)

if ~isstruct(source)
    return;
end

fields = fieldnames(source);
for ii = 1:numel(fields)
    field = fields{ii};
    target.(field) = source.(field);
end
