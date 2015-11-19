classdef RdtClient < handle
    % RdtClient Utility for browsing a remote repository.
    %   Holds toolbox configuration and other arguments to simplify
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
            obj.cd();
        end
        
        function wrp = cd(obj, varargin)
            % Change the working remote path.
            %   wrp = obj.cd() reset to repository root
            %   wrp = obj.cd('foo') append to the working path
            %   wrp = obj.cd('/foo') set the whole working path
            %   wrp = obj.cd('..') back up to path parent
            
            parser = rdtInputParser();
            parser.addOptional('remotePath', '', @ischar);
            parser.parse(varargin{:});
            remotePath = parser.Results.remotePath;
            
            if isempty(remotePath)
                % reset to root
                wrp = '/';
            elseif strcmp('..', remotePath)
                % back up
                parentPath = fileparts(obj.workingRemotePath);
                wrp = parentPath;
            elseif '/' == remotePath(1)
                % set absolute
                wrp = remotePath;
            else
                % set relative
                wrp = fullfile(obj.workingRemotePath, remotePath);
            end
            obj.workingRemotePath = wrp;
        end
        
        function artifacts = listArtifacts(obj, varargin)
            % List remote artifacts under a remote path.
            %   artifacts = obj.listArtifacts() use obj.workingRemotePath
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
        
        function remotePaths = listRemotePaths(obj)
            % List remote paths to artifacts.
            %   remotePaths = obj.listRemotePaths() list all paths
            remotePaths = rdtListRemotePaths(obj.configuration);
        end
        
        % search artifacts
        
        % read artifact (optional remotePath)
        
        % read artifats
        
        % artifact url (extract url for artifact or artifacts)
        
        % credentials dialog
        
        % open browser (server, repo, or artifact?)
        
        % publish artifact
        
        % publish artifacts
    end
    
    methods (Static)
        function withDots = slashesToDots(withSlashes)
            % Swap path style from slashes to dots: /foo/bar/ -> foo.bar
            
            if isempty(withSlashes)
                withDots = '';
                return;
            end
            
            % strip off extra delimiters at the ends
            if '/' == withSlashes(1)
                first = 2;
            else
                first = 1;
            end
            if '/' == withSlashes(end)
                last = numel(withSlashes) - 1;
            else
                last = numel(withSlashes);
            end
            withDots = withSlashes(first:last);
            
            % convert path separators to subgroup dots
            withDots('/' == withDots) = '.';
        end
    end
end