% Method to initialize a channelOBJ
function openConnection(obj)
    % Load JAVA libs
    import java.io.IOException;
    import java.io.FileInputStream;
    import java.io.BufferedInputStream;
    import java.io.File;
 
    % Load ganumed-ssh2 library
    import ch.ethz.ssh2.SFTPv3Client;
    import ch.ethz.ssh2.Connection;
    import ch.ethz.ssh2.Session;
    import ch.ethz.ssh2.SFTPv3FileHandle;
    
    try
        obj.channelOBJ = Connection(obj.serverName);
        obj.channelOBJ.connect();
    catch
        error('Could not connect to server ''%s''',obj.serverName);
    end 
end

