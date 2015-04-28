function varargout = v_SFTPConnection(varargin)
%
% Test SFTP connection from Matlab 
%

varargout = UnitTest.runValidationRun(@ValidationFunction, nargout, varargin);
end

function ValidationFunction(runTimeParams)

    % Create a couple of matfiles with dummy data to test transmission
    localFileName1 = 'file1.mat';
    data1 = rand(50,100,1);
    save(localFileName1, 'data1');
    
    localFileName2 = 'file2.mat';
    data2 = rand(200,100,1);
    save(localFileName2, 'data2');
    
    theServerName = 'crimson.stanford.edu';
    theUserName = input(sprintf('Enter username for ''%s'': ', theServerName), 's');
    
    % Instantiate a RemotDataHandler object
    validationRemoteDataHandler = RemoteDataHandler(...
        'serverName', theServerName,...
        'userName',theUserName);
            
    % Start an SFTP session to transmit the files
    validationRemoteDataHandler.startSFTPsession();
    
    % send file1
    destinationOnServer = 'validation/SCIEN/ISETBIO/fullvalidation/testDirectory3';
    validationRemoteDataHandler.sendFile(localFileName1, destinationOnServer);

    % send file2
    destinationOnServer = 'validation/SCIEN/ISETBIO/fullvalidation/testDirectory4';
    validationRemoteDataHandler.sendFile(localFileName2, destinationOnServer);
    
    % 
    validationRemoteDataHandler.terminateSFTPsession();
    validationRemoteDataHandler.shutdown;
    
    UnitTest.validationRecord('SIMPLE_MESSAGE', sprintf('sFTP connection to %s was successful.', theServerName));
    
end


