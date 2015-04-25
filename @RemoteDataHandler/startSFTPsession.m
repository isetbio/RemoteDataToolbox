function startSFTPsession(obj)
    % Load ganumed-ssh2 library
    import ch.ethz.ssh2.SFTPv3Client;
    import ch.ethz.ssh2.Connection;
    import ch.ethz.ssh2.Session;
    import ch.ethz.ssh2.SFTPv3FileHandle;
    
    % Open sFTP session
    obj.sFTPClientOBJ = SFTPv3Client(obj.channelOBJ);
    fprintf('Opened sFTPclient.\n');
end

