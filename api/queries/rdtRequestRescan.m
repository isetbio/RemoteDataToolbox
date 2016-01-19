function [isScanning, message] = rdtRequestRescan(configuration, varargin)
%% Request Archiva to re-scan a repository for artifact listings.
%
% [isScanning, message] = rdtRequestRescan(configuration) requests a
% repository re-scan from an Archiva Maven repository.  If successful, this
% will cause the repository artifact listing and search index to be
% re-generated immediately.  This may be useful when modifying the
% repository contents. configuration.serverUrl must point to the Archiva
% server root.  configuration.repositoryName must contain the id of an
% existing Archiva repository on the same server.
%
% Re-scanning an repository requires an Archiva user with the "run indexer"
% permission.  This permission is separate from the usual permissions
% required to read and write the repository contents.  As a result, this
% command will only succeed if the give configuration contains credentials
% for an Archiva system administrator.
%
% On success, this function will *initiate* the re-scan.  It may take some
% time for the scan to be completed.  For small repositories, the time
% required should be less than a second.  Still, there may be a "race
% condition" between the completion of the re-scan and any listing or
% searching requests you invoke after this function.
%
% rdtRequestRescan( ... 'timeout', timeout) waits after requesting the
% re-scan until the given timeout in seconds has elapsed, or the Archiva
% server reports that the scan is complete.
%
% Returns a logical value, true only if the server responded with a success
% message.  Also returns a string message from the server in case of
% success or failure.
%
% [isScanning, message] = rdtRequestRescan(configuration, varargin)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('configuration');
parser.addParameter('timeout', 0, @isnumeric);
parser.parse(configuration, varargin{:});
configuration = rdtConfiguration(parser.Results.configuration);
timeout = parser.Results.timeout;

isScanning = false;
message = '';

%% Request the re-scan.
scanPath = '/restServices/archivaServices/repositoriesService/scanRepositoryNow';
scanConfig = configuration;
scanConfig.acceptMediaType = 'text/plain';
scanParams = struct( ...
    'repositoryId', scanConfig.repositoryName, ...
    'fullScan', 1);

try
    message = rdtRequestWeb(scanConfig, scanPath, 'queryParams', scanParams);
    isScanning = true;
    
    % wait for the re-scan to complete?
    if timeout > 0
        rdtPrintf(scanConfig.verbosity, ...
            '%.1f second timeout for rescan to finish...', timeout);
        
        % ask the server if it's done yet
        ticToc = tic();
        endTime = timeout + toc(ticToc);
        alreadyScanning = true;
        while alreadyScanning && toc(ticToc) < endTime
            alreadyScanning = requestAlreadyScanning(scanConfig);
            pause(.1);
        end
        
        rdtPrintf(scanConfig.verbosity, 'done!\n');
    end
catch ex
    message = ex.message;
end

% Check if the requested repository is already being scanned.
function alreadyScanning = requestAlreadyScanning(configuration)
alreadyScanningPath = [ ...
    '/restServices/archivaServices/repositoriesService/alreadyScanning/' ...
    configuration.repositoryName];
try
    alreadyMessage = rdtRequestWeb(scanConfig, alreadyScanningPath);
    alreadyScanning = strcmpi('true', alreadyMessage);
catch
    alreadyScanning = false;
end
