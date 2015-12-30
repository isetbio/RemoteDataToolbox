classdef RdtClient < handle
    % RdtClient Utility for interactions with a remote Archiva repository.
    %
    % Data slots in this object are:
    %
    %   configuration: Holds the remote configuration 
    %   workingRemotePath: Holds a working remote path 
    %
    % The remote path simplifies calls to the plain-old-function API.
    
    properties
        % toolbox configuration
        configuration;
    end
    
    properties (SetAccess = protected)
        % working path in remote repository
        workingRemotePath;
    end
    
    methods
        function obj = RdtClient(configuration)
            % save toolbox config for use with this object
            obj.configuration = rdtConfiguration(configuration);
            
            % start out at repository root
            obj.crp('/');
        end
        
        function wrp = pwrp(obj)
            % Print working remote path
            wrp = obj.workingRemotePath;
        end
        
        function wrp = crp(obj, varargin)
            % Change the working remote path. 
            % (For consistency, could be cwrp, rather than crp - BW).
            % (Was attempting to mimic shell commands cd and pwd - BSH).
            % This works exactly the way cd works.
            %
            %   wrp = obj.crp() just return working remote path
            %   wrp = obj.crp('/') reset to repository root
            %   wrp = obj.crp('/foo') set the whole working path
            %   wrp = obj.crp('foo') append to the working path
            %   wrp = obj.crp('..') back up to path parent
            
            parser = rdtInputParser();
            parser.addOptional('remotePath', '', @ischar);
            parser.parse(varargin{:});
            remotePath = parser.Results.remotePath;
            
            if isempty(remotePath)
                % just print
                wrp = obj.workingRemotePath;
            elseif '/' == remotePath(1)
                % set absolute
                if numel(remotePath) < 2
                    wrp = '';
                else
                    wrp = remotePath(2:end);
                end
            elseif strcmp('..', remotePath)
                % back up to parent
                pathParts = rdtPathParts(obj.workingRemotePath);
                wrp = rdtFullPath(pathParts(1:end-1));
            else
                % set relative
                pathParts = rdtPathParts(obj.workingRemotePath);
                pathParts = cat(2, pathParts, {remotePath});
                wrp = rdtFullPath(pathParts);
            end
            obj.workingRemotePath = wrp;
        end
        
        function remotePaths = listRemotePaths(obj)
            % List remote paths to artifacts.
            %   remotePaths = obj.listRemotePaths() list all paths
            remotePaths = rdtListRemotePaths(obj.configuration);
        end
        
        function artifacts = listArtifacts(obj, varargin)
            % List artifacts under a remote path.
            %   artifacts = obj.listArtifacts() use pwrp()
            %   artifacts = obj.listArtifacts(remotePath) use remotePath
            
            parser = rdtInputParser();
            parser.addOptional('remotePath', obj.workingRemotePath, @ischar);
            parser.parse(varargin{:});
            remotePath = parser.Results.remotePath;
            
            if isempty(remotePath)
                % list all artifacts by iterating remote paths
                remotePaths = obj.listRemotePaths();
                nRemotePaths = numel(remotePaths);
                artifactCollection = cell(1, nRemotePaths);
                for ii = 1:nRemotePaths
                    artifactCollection{ii} = ...
                        rdtListArtifacts(obj.configuration, remotePaths{ii});
                end
                artifacts = [artifactCollection{:}];
                
            else
                % list under the known path
                artifacts = rdtListArtifacts(obj.configuration, remotePath);
            end
        end
        
        function artifacts = searchArtifacts(obj, searchText, varargin)
            % Search for remote artifacts by fuzzy text matching.
            %   artifacts = obj.searchArtifacts(text) match against text
            %   ( ... 'remotePath', remotePath) remotePath instead of pwrp()
            %   ( ... 'artifactId', artifactId) restrict to artifactId
            %   ( ... 'version', version) restrict to version
            %   ( ... 'type', type) restrict to type
            
            parser = rdtInputParser();
            parser.addRequired('searchText', @ischar);
            parser.addParameter('remotePath', obj.workingRemotePath, @ischar);
            parser.parse(searchText, varargin{:});
            searchText = parser.Results.searchText;
            remotePath = parser.Results.remotePath;
            
            artifacts = rdtSearchArtifacts(obj.configuration, ...
                searchText, varargin{:}, 'remotePath', remotePath);
        end
        
        function [data, artifact] = readArtifact(obj, artifactId, varargin)
            % Read data for one artifact into Matlab.
            % The artifactID 
            %   [data, artifact] = obj.readArtifact(artifactId)
            %   ( ... 'remotePath', remotePath) remotePath instead of pwrp()
            %   ( ... 'version', version) version instead of default latest
            %   ( ... 'type', type) type instead of default 'mat'
            
            parser = rdtInputParser();
            parser.addRequired('artifactId', @ischar);
            parser.addParameter('remotePath', obj.workingRemotePath, @ischar);
            parser.parse(artifactId, varargin{:});
            artifactId = parser.Results.artifactId;
            remotePath = parser.Results.remotePath;
            
            [data, artifact] = rdtReadArtifact(obj.configuration, ...
                remotePath, artifactId, varargin{:});
        end
        
        function [datas, artifacts] = readArtifacts(obj, pathOrArtifacts)
            % Read data for multiple artifacts into Matlab.
            %   [datas, artifacts] = obj.readArtifacts() all under pwrp()
            %   obj.readArtifacts(remotePath) remotePath instead of pwrp()
            %   obj.readArtifacts(artifacts) explicit artifact struct array
            
            datas = {};
            artifacts = {};
            
            if nargin < 2 || isempty(pathOrArtifacts)
                % all under pwrp()
                artifacts = obj.listArtifacts();
                [datas, artifacts] = rdtReadArtifacts(obj.configuration, artifacts);
                
            elseif ischar(pathOrArtifacts)
                % all under remote path
                artifacts = rdtListArtifacts(obj.configuration, pathOrArtifacts);
                [datas, artifacts] = rdtReadArtifacts(obj.configuration, artifacts);
                
            elseif isstruct(pathOrArtifacts)
                % explicit struct array
                [datas, artifacts] = rdtReadArtifacts(obj.configuration, pathOrArtifacts);
            end
        end
        
        function artifact = publishArtifact(obj, file, varargin)
            % Publish a file as an artifact to a remote repository.
            %   artifact = obj.publishArtifact(file)
            %   ( ... 'remotePath', remotePath) remotePath instead of pwrp()
            %   ( ... 'artifactId', artifactId) artifactId instead of name
            %   ( ... 'version', version) version instead of default '1'
            
            parser = rdtInputParser();
            parser.addRequired('file', @ischar);
            parser.addParameter('remotePath', obj.workingRemotePath, @ischar);
            parser.parse(file, varargin{:});
            file = parser.Results.file;
            remotePath = parser.Results.remotePath;
            
            artifact = rdtPublishArtifact(obj.configuration, ...
                file, remotePath, varargin{:});
        end
        
        function artifacts = publishArtifacts(obj, folder, varargin)
            % Publish files in a folder as artifacts to a remote repository.
            %   artifact = obj.publishArtifact(folder)
            %   ( ... 'remotePath', remotePath) remotePath instead of pwrp()
            %   ( ... 'version', version) version instead of default '1'
            %   ( ... 'type', type) restruct to type
            
            parser = rdtInputParser();
            parser.addRequired('folder', @ischar);
            parser.addParameter('remotePath', obj.workingRemotePath, @ischar);
            parser.parse(folder, varargin{:});
            folder = parser.Results.folder;
            remotePath = parser.Results.remotePath;
            
            artifacts = rdtPublishArtifacts(obj.configuration, ...
                folder, remotePath, varargin{:});
        end
        
        function credentialsDialog(obj)
            % Prompt for username and password with obsucre typing.
            obj.configuration = rdtCredentialsDialog(obj.configuration);
        end
        
        % Print to the console, hiding the password
        function disp(obj)
            c = obj.configuration;
            fprintf('\n');
            fprintf('Repository:     %s\n',c.repositoryName);
            fprintf('User:           %s\n',c.username);
            fprintf('Repository URL: %s\n',c.repositoryUrl');
            fprintf('Sever URL:      %s\n',c.serverUrl);
            if isempty(obj.workingRemotePath)
                fprintf('Root working path\n');
            else
                fprintf('Working path:   %s\n',obj.workingRemotePath);
            end
            fprintf('\n');
        end
        
        
        function url = openBrowser(obj, varargin)
            % View a server, repository, or artifact in a Web browser.
            %   url = openBrowser() open pwrp()
            %   url = openBrowser(whichUrl) open obj.configuration.whichUrl
            %   url = openBrowser(artifact) open artifact.url
            
            parser = rdtInputParser();
            parser.addOptional('whichUrlOrArtifact', []);
            parser.parse(varargin{:});
            whichUrlOrArtifact = parser.Results.whichUrlOrArtifact;
            
            url = '';
            
            if isempty(whichUrlOrArtifact)
                % If there is no argument, then we open the repository URL,
                % appending the working directory.
                % open pwrp()
                repoParts = rdtPathParts(obj.configuration.repositoryUrl);
                remotePathParts = rdtPathParts(obj.workingRemotePath);
                pathParts = cat(2, repoParts, remotePathParts);
                url = rdtFullPath(pathParts, 'hasProtocol', true);
                
                % Tell the open browser that we are sending in a full URL
                rdtOpenBrowser(struct('url', url), 'url');
                
            elseif isstruct(whichUrlOrArtifact)
                % open the browser at the URL of the named artifact
                url = rdtOpenBrowser(whichUrlOrArtifact);
                
            elseif ischar(whichUrlOrArtifact)
                % A string was sent in.  We assume this is the URL
                url = rdtOpenBrowser(obj.configuration, whichUrlOrArtifact);
            end
        end
    end
end
