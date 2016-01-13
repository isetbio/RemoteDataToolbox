function [isConnected, message] = rdtPingServer(configuration)
%% Ping an Archiva Maven repository check if it's available.
%
% [isConnected, message] = rdtPingServer(configuration) requests a "ping"
% response from an Archiva Maven repository. configuration.serverUrl must
% point to the Archiva server root.  If configuration.password is empty,
% makes a generic "ping" request that just checks if the server is
% available.  Otherwise, makes and authenticating "ping" request that only
% succeeds if the provided credentials are accepted by the server.
%
% Returns a logical value, true only if the server responded with a success
% message.  Also returns a string message from the server in case of
% success or failure.
%
% [isConnected, message] = rdtPingServer(configuration)
%
% Copyright (c) 2015 RemoteDataToolbox Team

configuration = rdtConfiguration(configuration);

isConnected = false;
message = '';

%% Generic or authenticated ping?
if isempty(configuration.password)
    pingPath = '/restServices/archivaServices/pingService/ping';
else
    pingPath = '/restServices/archivaServices/pingService/pingWithAuthz';
end

%% Ping the Archiva server.
try
    pingConfig = configuration;
    pingConfig.acceptMediaType = 'text/plain';
    message = rdtRequestWeb(pingConfig, pingPath);
    isConnected = true;
catch ex
    message = ex.message;
end
