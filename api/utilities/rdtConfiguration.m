function [configuration, flavor] = rdtConfiguration(varargin)
%% Initialize a struct with RemoteDataToolbox configuration.
%
% This function initializes a config struct that you can pass to other
% toolbox functions.  Config fields start out with default values declared
% in this function.  These may be amended with values read from a named
% JSON-file or passed in as a struct or name-value pairs.
%
%   configuration = rdtConfiguration(projectName) 
%
% uses the given name to locate a JSON file that contains configuration
% values.  For example, if projectName is "foo", searches for the file
% "rdt-config-foo.json".  First searches pwd(), then the parent folders of
% pwd(), then the Matlab path.
%
%   configuration = rdtConfiguration(jsonFile) 
%
% loads configuration values from the given jsonFile.
%
%   configuration = rdtConfiguration(initialConfig) 
%
% amends the default configuration using fields from the given
% initialConfig struct.
%
%   configuration = rdtConfiguration('field1', value1, 'field2', value2, ...)
% 
% amends the default configuration using the named field-value pairs.
%
% This function may pop up a dialog prompting you to enter a configuration
% username and password.  The dialog will pop up only if two conditions are
% met:
%   1. configuration.username is not empty and not "guest", and
%   2. configuration.password is empty
%
% Used this way:
%
%   [configuration, flavor] = rdtConfiguration(varargin)
%
% Returns a struct with toolbox configuration with at least the default
% fields and values.  Also returns a "flavor" string describing where the
% configuration came from (e.g. "defaults", "foo.json", etc.).
%
% Copyright (c) 2015 RemoteDataToolbox Team

%% What did the user pass in?
flavor = 'default configuration';
configArgs = {};
if 1 == nargin
    arg = varargin{1};
    if ischar(arg)
        % struct from project name or json file path
        [configArgs{1}, flavor] = configFromJson(arg);
    elseif isstruct(arg)
        % explicit struct
        flavor = 'explicit configuration struct';
        configArgs = {arg};
    end
else
    % explicit name-value pairs
    flavor = 'explicit configuration parameters';
    configArgs = varargin;
end

%% Declare expected args and default values.
parser = rdtInputParser();
parser.StructExpand = true;
parser.addParameter('serverUrl', '', @ischar);
parser.addParameter('repositoryUrl', '', @ischar);
parser.addParameter('repositoryName', '', @ischar);
parser.addParameter('username', 'guest', @ischar);
parser.addParameter('password', '', @ischar);
parser.addParameter('requestMediaType', 'application/json', @ischar);
parser.addParameter('acceptMediaType', 'application/json', @ischar);
parser.addParameter('cacheFolder', '', @ischar);
parser.addParameter('verbosity', 0, @isnumeric);

%% Parse given config through the declared config scheme.
parser.parse(configArgs{:});
configuration = rdtMergeStructs(parser.Results, parser.Unmatched, true);

%% Prompt for credentials if needed.
if isempty(configuration.password) ...
        && ~isempty(configuration.username) ...
        && ~strcmp('guest', configuration.username)
    
    % got a real username and no password -- ask for the password
    flavor = [flavor ' and credentials dialog'];
    configuration = rdtCredentialsDialog(configuration);
end

rdtPrintf(configuration.verbosity, 'Configuration source "%s"\n', flavor);

%% Load config from a JSON file.
function [configArgs, flavor] = configFromJson(arg)

configArgs = struct();

[~, argBase, argExt] = fileparts(arg);
if strcmp('.json', argExt) && 2 == exist(arg, 'file')
    % got explicit path to a JSON file
    flavor = sprintf('explicit file: %s', arg);
    configArgs = rdtFromJson(arg);
    return;
end

% got a project name foo, search for rdt-config-foo.json
jsonFileName = ['rdt-config-' argBase '.json'];

% search the current folder and its parents
projectConfig = rdtSearchParentFolders(jsonFileName, pwd());
if 2 == exist(projectConfig, 'file')
    flavor = sprintf('config for project %s: %s', arg, projectConfig);
    configArgs = rdtFromJson(projectConfig);
    return;
end

% search the Matlab path
pathConfig = which(jsonFileName);
if ~isempty(pathConfig)
    flavor = sprintf('config from Matlab path: %s', pathConfig);
    configArgs = rdtFromJson(pathConfig);
    return;
end

% unable to locate JSON
flavor = sprintf('json not found: %s or %s', arg, jsonFileName);
