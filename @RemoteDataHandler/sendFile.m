% Method to send a local file to a destination folder on the FTP server
function sendFile(obj, localFileName, destinationOnServer)
    
    import java.io.IOException;
    import java.io.FileInputStream;
    import java.io.BufferedInputStream;
    import java.io.File;
    
    % Assemble full path to remote file 
    remoteFileName = fullfile(destinationOnServer,localFileName);
    
    % Check whether we need to create the destination directory
    try
        obj.sFTPClientOBJ.lstat(destinationOnServer).isDirectory;
    catch err
        % directory does not exist. So create it.
        createDir = input(sprintf('''%s'' does not exist on ''%s''. Create it ? [1=yes]: ', destinationOnServer, obj.serverName));
        if (createDir == 1)
            obj.sFTPClientOBJ.mkdir(destinationOnServer, oct2dec(0775));
        end
    end
       
    % Create local file
    obj.sFTPClientOBJ.createFile(remoteFileName);
    
    % Create remote file
    remoteFID = obj.sFTPClientOBJ.openFileRW(remoteFileName);

    % Open a buffer stream
    buffer  = zeros(1,1024);
    bufferOBJ = BufferedInputStream(FileInputStream(localFileName));
    
    % Transfer file
    try
        fprintf('\n Transmitting file ''%s''.\n', localFileName);
        count = 0;
        bufsize = bufferOBJ.read(buffer);
        while (bufsize~=-1)
            obj.sFTPClientOBJ.write(remoteFID,count,buffer,0,bufsize);
            count   = count + bufsize;
            bufsize = bufferOBJ.read(buffer);
            fprintf('Bytes sent: %d\n', count);
        end   
    catch
       error('Failed during writing to server %s (bytes sent = %d)',obj.serverName, count);
    end

    fprintf('\nTotal bytes sent: %d.\n', count);
end

