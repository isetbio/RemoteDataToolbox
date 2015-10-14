%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Initialize configuration struct and prompt for user credentials.
%   @param varargin a file path, a struct, or multiple name-value pairs
%
% @details
% This funciton allows you to enter you username and password for use with
% Remote Data Toolbox, without typing your password into the command
% window.  This is good because others may be able to read what you type in
% the command window.
%
% @details
% @a varargin will be passed to rdtConfiguration() to create an initial
% configuration struct.  Then a dialog will be raised to prompt for a
% username and password.  These values will be saved in the configuration
% struct.
%
% @details
% Returns a struct of RemoteDataToolbox configuration which may include
% secret credentials.
%
% @details
% Usage:
%   configuration = rdtConfiguration(varargin)
%
% @ingroup utilities
function configuration = rdtCredentialsDialog(varargin)

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
