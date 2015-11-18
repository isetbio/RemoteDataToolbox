%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Initialize a struct with RemoteDataToolbox configuration
%   @param varargin a project name, file path, struct, or name-value pairs
%
% @details
% @a varargin may have one of four forms:
%   - a string project name used to find a JSON-file
%   - an explicit file path to a JSON-file
%   - a struct containing multiple field-value pairs of configuration
%   - a list of multiple name-value pairs of configuration
%
% @details
% If @a varargin is a project name, for example @b foo, searches for a file
% named @b rdt-config-foo.json.  First searches the current folder (pwd()),
% then the parent folders of pwd(), then the Matlab path.
%
% @details
% Initializes a struct containing RemoteDataToolbox configuration.
% Configuration values begin with defaults declared in this function.
% These may be overridden by values from the named JSON-file or given
% struct or name-value pairs.
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
configArgs = {};
if 0 == nargin
    fprintf('Using default config.\n');
elseif 1 == nargin
    arg = varargin{1};
    if ischar(arg)
        % struct from project name or json file path
        configArgs = {configFromJson(arg)};
    elseif isstruct(arg)
        % explicit struct
        fprintf('Using config from explicit struct.\n');
        configArgs = {arg};
    else
        fprintf('Using default config.\n');
    end
else
    % explicit name-value pairs
    fprintf('Using config from explicit name-value pairs.\n');
    configArgs = varargin;
end

%% Declare expected args and default values.
parser = rdtInputParser();
parser.StructExpand = true;
parser.addParameter('serverUrl', '');
parser.addParameter('repositoryUrl', '');
parser.addParameter('repositoryName', '');
parser.addParameter('username', 'guest');
parser.addParameter('password', '');
parser.addParameter('requestMediaType', 'application/json');
parser.addParameter('acceptMediaType', 'application/json');
parser.addParameter('cacheFolder', '');

%% Parse the input through the input scheme.
parser.parse(configArgs{:});
configuration = rdtMergeStructs(parser.Results, parser.Unmatched, true);

%% Load config from a JSON file.
function configArgs = configFromJson(arg)

configArgs = struct();

if 2 == exist(arg, 'file')
    % got explicit path to a JSON file
    fprintf('Using config from explicit file: %s\n', arg);
    configArgs = rdtFromJson(arg);
    return;
end

% got a project name foo, search for rdt-config-foo.json
jsonFileName = ['rdt-config-' arg '.json'];

% search the current folder and its parents
projectConfig = rdtSearchParentFolders(jsonFileName, pwd());
if 2 == exist(projectConfig, 'file')
    fprintf('Using config for "%s" project: %s\n', arg, projectConfig);
    configArgs = rdtFromJson(projectConfig);
    return;
end

% search the Matlab path
pathConfig = which(jsonFileName);
if ~isempty(pathConfig)
    fprintf('Using config from Matlab path: %s\n', pathConfig);
    configArgs = rdtFromJson(pathConfig);
    return;
end

% unable to locate JSON
fprintf('Could not find config named "%s" or "%s"\n', arg, jsonFileName);