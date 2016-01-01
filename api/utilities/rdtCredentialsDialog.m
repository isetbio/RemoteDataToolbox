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
    'WindowName', 'Remote Data Toolbox Password');

if ischar(password)
    configuration.username = username;
    configuration.password = password;
end
