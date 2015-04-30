% Method to shutdown the DataHandlerObject
function shutdown(obj)
    obj.terminateSFTPsession();
    if (~isempty(obj.channelOBJ))
        obj.channelOBJ.close(); 
        obj.channelOBJ = [];
        fprintf('Closed communication channel to ''%s''.\n', obj.serverName);
    end
    obj.isInitialized = false;
end
