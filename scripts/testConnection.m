function testConnection
    
    % Create a couple of matfiles with dummy data to test transmission
    localFileName1 = 'file1.mat';
    data1 = rand(50,100,1);
    save(localFileName1, 'data1');
    
    localFileName2 = 'file2.mat';
    data2 = rand(200,100,1);
    save(localFileName2, 'data2');
    
    % Instantiate a RemotDataHandler object
    validationRemoteDataHandler = RemoteDataHandler(...
        'serverName', 'crimson.stanford.edu',...
        'userName','nicolas');
            
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
end


