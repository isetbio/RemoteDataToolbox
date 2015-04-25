classdef RemoteDataHandler < handle
    %RemoteDataHandler Class to handle uploading and downloading files to a remote ftp server.
    %   Usage:
    
    % Public properties
    properties
    end
    
    % Read-only public properties
    properties (SetAccess = private)
        % Flag indicating whether the object has been initialized
        isInitialized;
        
        % Address of ftp server
        serverName = 'someServer.someUniversity.edu';
        
        % Name of user to login to the above server
        userName = 'someUser';
        
    end
    
    % Private properties
    properties (Access = private)
        
        % SSH-2 connection channel object
        channelOBJ = [];
        
        % secure SFTP v3 client object
        sFTPClientOBJ = [];
    end
    
    properties (Constant)
    end
    
    % Public methods (This is the public API)
    methods
        % Constructor
        function obj = RemoteDataHandler(varargin) 
            % Parse input key/value pairs
            parser = inputParser;
            parser.addParamValue('serverName', obj.serverName, @ischar);
            parser.addParamValue('userName', obj.userName, @ischar);
            % Execute the parser to make sure input is good
			parser.parse(varargin{:});
            pNames = fieldnames(parser.Results);
            for k = 1:length(pNames)
               obj.(pNames{k}) = parser.Results.(pNames{k});
            end  
            % Initialize the instantiated @RemoteDataHandler object
            obj.isInitialized = false;
            obj.importJavaLibs();
            obj.openConnection();
            obj.authenticateUser();
            obj.isInitialized = true;
        end
        
        % Method to shutdown the DataHandlerObject
        shutdown(obj);
        
        % Method to start an sFPT session
        startSFTPsession(obj);
        
        % Method to terminate an sFTP session
        terminateSFTPsession(obj);
        
        % Method to send a local file to a destination folder on the FTP server
        sendFile(obj, localFileName, destinationOnServer);
    
    end % public methods
    
    methods (Access = private)
       importJavaLibs(obj);
       openConnection(obj);
       authenticateUser(obj);
    end
end

