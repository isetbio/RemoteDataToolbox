classdef RdtClient < handle
    % RdtClient Utility for browsing a remote repository.
    %   Holds toolbox configuration and working to simplify
    %   calls to the plain-old-function API.
    
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
            obj.crp();
        end
        
        function wrp = pwrp(obj)
            % Print and return the working remote path.
            
            wrp = obj.workingRemotePath;
            disp(wrp);
        end
        
        function wrp = crp(obj, varargin)
            % Change the working remote path.
            %   wrp = obj.crp() just return working path
            %   wrp = obj.crp('/') reset to repository root
            %   wrp = obj.crp('/foo') set the whole working path
            %   wrp = obj.crp('foo') append to the working path
            %   wrp = obj.crp('..') back up to path parent
            
            parser = rdtInputParser();
            parser.addOptional('remotePath', '', @ischar);
            parser.parse(varargin{:});
            remotePath = parser.Results.remotePath;
            
            if isempty(remotePath)
                % reset to root
                wrp = obj.workingRemotePath;
            elseif '/' == remotePath(1)
                % set absolute
                wrp = remotePath;
            elseif strcmp('..', remotePath)
                % back up
                parentPath = fileparts(obj.workingRemotePath);
                wrp = parentPath;
            else
                % set relative
                wrp = fullfile(obj.workingRemotePath, remotePath);
            end
            obj.workingRemotePath = wrp;
        end
        
        function remotePaths = listRemotePaths(obj)
            % List remote paths to artifacts.
            %   remotePaths = obj.listRemotePaths() list all paths
            remotePaths = rdtListRemotePaths(obj.configuration);
        end
        
        function artifacts = listArtifacts(obj, varargin)
            % List remote artifacts under a remote path.
            %   artifacts = obj.listArtifacts() use pwrp()
            %   artifacts = obj.listArtifacts(remotePath) use remotePath
            
            parser = rdtInputParser();
            parser.addOptional('remotePath', obj.workingRemotePath, @ischar);
            parser.parse(varargin{:});
            remotePath = RdtClient.slashesToDots(parser.Results.remotePath);
            
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
            % Search for artifacts by fuzzy text matching.
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
            
            if remotePath == '/'
                remotePath = '';
            end
            
            artifacts = rdtSearchArtifacts(obj.configuration, ...
                searchText, varargin{:}, 'remotePath', remotePath);
        end
        
        function [data, artifact] = readArtifact(obj, artifactId, varargin)
            % Read data for one artifact into Matlab.
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
            
            if remotePath == '/'
                remotePath = '';
            end
            
            [data, artifact] = rdtReadArtifact(obj.configuration, ...
                artifactId, varargin{:}, 'remotePath', remotePath);
        end
        
        function [datas, artifacts] = readArtifacts(obj, varargin)
            % Read data for multiple artifacts into Matlab.
            %   [datas, artifacts] = obj.readArtifacts() all under pwrp()
            %   obj.readArtifacts(remotePath) remotePath instead of pwrp()
            %   obj.readArtifacts(artifacts) explicit artifact struct array
            
            parser = rdtInputParser();
            parser.addOptional('pathOrArtifacts', []);
            parser.parse(varargin{:});
            pathOrArtifacts = parser.Results.whichUrlOrArtifact;
            
            datas = {};
            artifacts = {};
            
            if isempty(pathOrArtifacts)
                % all under pwrp()
                artifacts = rdtListArtifacts(obj.configuration, obj.workingRemotePath);
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
            % Publish file in a folder as artifacts to a remote repository.
            %   artifact = obj.publishArtifact(file)
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
            obj.configuration = rdtCredentialsDialog(obj.configuration);
        end
        
        function url = openBrowser(obj, varargin)
            % View a server, repository or artifact in a browser.
            %   url = openBrowser() open pwrp()
            %   url = openBrowser(whichUrl) open obj.configuration.whichUrl
            %   url = openBrowser(artifact) open artifact.url
            
            parser = rdtInputParser();
            parser.addOptional('whichUrlOrArtifact', []);
            parser.parse(varargin{:});
            whichUrlOrArtifact = parser.Results.whichUrlOrArtifact;
            
            url = '';
            
            if isempty(whichUrlOrArtifact)
                % open pwrp()
                repoParts = rdtPathParts(obj.configuration.repositoryUrl, 'separator', '/');
                remotePathParts = rdtPathParts(obj.workingRemotePath, 'separator', '/');
                pathParts = cat(2, repoParts, remotePathParts);
                url = rdtFullPath(pathParts, 'separator', '/');
                placeholder.url = url;
                rdtOpenBrowser(placeholder, 'url');
                
            elseif isstruct(whichUrlOrArtifact)
                % open artifact
                url = rdtOpenBrowser(whichUrlOrArtifact);
                
            elseif ischar(whichUrlOrArtifact)
                % open whichUrl
                url = rdtOpenBrowser(obj.configuration, whichUrlOrArtifact);
            end
        end
    end
    
    methods (Static)
        function withDots = slashesToDots(withSlashes)
            pathParts = rdtPathParts(withSlashes, 'separator', '/');
            withDots = rdtFullPath(pathParts, 'separator', '.', ...
                'trimLeading', true, 'trimTrailing', true);
        end
    end
end