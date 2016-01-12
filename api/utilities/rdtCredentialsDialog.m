function configuration = rdtCredentialsDialog(configuration)
%% Initialize RemoteDataToolbox configuration and prompt for credentials.
%
% This function allows you to enter a username and password for use with
% Remote Data Toolbox, without typing your password into the command
% window.  Others may be able to read what you type in the command window
% or view your command history, so you should avoid typing secrets there.
%
% configuration = rdtCredentialsDialog(configuration) accepts an initial
% configuration struct, then prompts you to enter a username and password
% into a dialog which will obscure what you type.
%
% Returns the given initial configuration struct, with username and
% password filled in from what you typed.
%
% See also rdtConfiguration
%
% configuration = rdtCredentialsDialog(configuration)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('configuration', @isstruct);
parser.parse(configuration);
configuration = parser.Results.configuration;

% keep asking until cancel or successful credentials
tempConfiguration = configuration;
result = 'tryAgain';
prompt = 'Remote Server Password';
while strcmp('tryAgain', result)
    [tempConfiguration, result] = tryCredentials(tempConfiguration, prompt);
    prompt = 'Please Try Again';
end

% only keep configuration if credentials worked
if strcmp('connected', result)
    configuration = tempConfiguration;
end

%% Raise a credentials dialog and ping the server with the password.
function [configuration, result] = tryCredentials(configuration, prompt)
if isfield(configuration, 'username')
    usernameSuggestion = configuration.username;
else
    usernameSuggestion = 'username';
end

[password, username] = passwordEntryDialog( ...
    'enterUserName', true, ...
    'DefaultUserName', usernameSuggestion, ...
    'ValidatePassword', false, ...
    'CheckPasswordLength', false, ...
    'WindowName', prompt);

if ischar(password)
    % the user pressed OK
    configuration.username = username;
    configuration.password = password;
    
    % ping the server
    [isConnected, message] = rdtPingServer(configuration);
    if isConnected
        result = 'connected';
    else
        result = 'tryAgain';
        fprintf('Credentials not accepted:\n%s\n', message);
    end
else
    % the user pressed Cancel
    result = 'canceled';
end
