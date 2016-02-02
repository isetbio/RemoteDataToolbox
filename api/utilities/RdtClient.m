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
        
        function remotePaths = listRemotePaths(obj,varargin)
            % List remote paths to artifacts.
            %   remotePaths = obj.listRemotePaths() list all paths
            %   remotePaths = obj.ListRemotePaths('sortFlag',true); % Could be set to false
            remotePaths = rdtListRemotePaths(obj.configuration, varargin{:});
        end
        
        function artifacts = listArtifacts(obj, varargin)
            % List artifacts under a remote path.
            %   artifacts = obj.listArtifacts() % remotePath = pwrp()
            %   artifacts = obj.listArtifacts('remotePath', remotePath)
            %   artifacts = obj.listArtifacts('sortField', field); % default is sort by artifactId
            
            parser = rdtInputParser();
            parser.addParameter('remotePath', obj.workingRemotePath, @ischar);
            parser.addParameter('sortField', 'artifactId', @ischar);
            parser.parse(varargin{:});
            remotePath = parser.Results.remotePath;
            sortField = parser.Results.sortField;
            
            if isempty(remotePath)
                % list all artifacts by iterating remote paths
                remotePaths = obj.listRemotePaths();
                nRemotePaths = numel(remotePaths);
                artifactCollection = cell(1, nRemotePaths);
                for ii = 1:nRemotePaths
                    % pass remotePath parameter explicitly
                    % so it doesn't get squashed by varargin
                    artifactCollection{ii} = ...
                        rdtListArtifacts(obj.configuration, ...
                        remotePaths{ii}, ...
                        varargin{:}, ...
                        'remotePath', remotePaths{ii});
                end
                artifacts = rdtSortStructArray([artifactCollection{:}], sortField);
                
            else
                % list under the known path
                artifacts = rdtListArtifacts(obj.configuration, ...
                    remotePath, varargin{:});
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
        
        function [data, artifact, downloads] = readArtifact(obj, artifactId, varargin)
            % Read data for one artifact into Matlab.
            %
            % You must supply the artifactId of the artifact you want to
            % read.  This is like the base name of the file, for example
            % the "foo" in "foo.txt".
            %
            % You must also supply the type of the artifact you want to
            % read.  This is like the file extension, for example the "txt"
            % in "foo.txt".  If you omit the type, the default, "mat" is
            % used.
            %
            % Finally, you must supply the "remotePath" to the artifact.
            % This is like the folder that contains a file, for example the
            % "/path/to/file" in "/path/to/file/foo.txt".  If you omit the
            % remotePath, the value of pwrp() is used.
            %
            % Note: you must supply the full remotePath where the artifact
            % is located.  For example, to read "/path/to/file/foo.txt",
            % you would have to supply the full "/path/to/file".  Supplying
            % "/path" or using crp("/path") would not be enough.
            %
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
            
            [data, artifact, downloads] = rdtReadArtifact(obj.configuration, ...
                remotePath, artifactId, varargin{:});
        end
        
        function [datas, artifacts, downloads] = readArtifacts(obj, pathOrArtifacts)
            % Read data for multiple artifacts into Matlab.
            %   [datas, artifacts] = obj.readArtifacts() all under pwrp()
            %   obj.readArtifacts(remotePath) remotePath instead of pwrp()
            %   obj.readArtifacts(artifacts) explicit artifact struct array
            
            datas = {};
            artifacts = {};
            
            if nargin < 2 || isempty(pathOrArtifacts)
                % all under pwrp()
                artifacts = obj.listArtifacts();
                [datas, artifacts, downloads] = rdtReadArtifacts(obj.configuration, artifacts);
                
            elseif ischar(pathOrArtifacts)
                % all under remote path
                artifacts = rdtListArtifacts(obj.configuration, pathOrArtifacts);
                [datas, artifacts, downloads] = rdtReadArtifacts(obj.configuration, artifacts);
                
            elseif isstruct(pathOrArtifacts)
                % explicit struct array
                [datas, artifacts, downloads] = rdtReadArtifacts(obj.configuration, pathOrArtifacts);
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
            %   ( ... 'type', type) restrict to type
            
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
            % We use the actual variable names here so we can set them.
            c = obj.configuration;
            fprintf('\n');
            fprintf('repositoryName:     %s\n',c.repositoryName);
            fprintf('repositoryUrl:      %s\n',c.repositoryUrl');
            fprintf('serverUrl:          %s\n',c.serverUrl);
            if isempty(obj.workingRemotePath)
                fprintf('workingRemotePath:  Root\n');
            else
                fprintf('workingRemotePath:  %s\n',obj.workingRemotePath);
            end
            fprintf('username:           %s\n',c.username);
            fprintf('password:           %s\n','****');
            fprintf('verbosity:          %d\n',c.verbosity);
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
                url = rdtBuildArtifactUrl(obj.configuration.repositoryUrl, obj.workingRemotePath, '', '');
                
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
        
        function [isStarted, message] = requestRescan(obj, varargin)
            % Ask Archiva to rescan the repository to up-to-date artifact
            % listing and searching.
            %   [isStarted, message] = requestRescan() initiate scan
            %   [isStarted, message] = requestRescan('timeout',
            %       timeout) wait up to timeout seconds for scan to finish.
            
            [isStarted, message] = rdtRequestRescan(obj.configuration, ...
                varargin{:});
        end
    end
end
