function configuration = rdtCredentialsDialog(varargin)
%% Initialize RemoteDataToolbox configuration and prompt for credentials.
%
% This funciton allows you to enter a username and password for use with
% Remote Data Toolbox, without typing your password into the command
% window.  Others may be able to read what you type in the command window
% or view your command history, so you should avoid typing secrets there.
%
% configuration = rdtCredentialsDialog(varargin) passes varargin to
% rdtConfiguration() to obtain an initial config struct, then prompts you
% to enter a username and password into a dialog which will obscure what
% you type.
%
% Returns a struct with toolbox configuration which may include the
% username and password that you typed.
%
% See also rdtConfiguration
%
% configuration = rdtCredentialsDialog(varargin)
%
% Copyright (c) 2015 RemoteDataToolbox Team

configuration = rdtConfiguration(varargin{:});

[password, username] = passwordEntryDialog( ...
    'enterUserName', true, ...
    'DefaultUserName', configuration.username, ...
    'ValidatePassword', false, ...
    'CheckPasswordLength', false, ...
    'WindowName', 'Remote Data Toolbox Password');

if ischar(password)
    configuration.username = username;
    configuration.password = password;
end
