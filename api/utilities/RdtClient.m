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
            % List remote paths to artifacts.  The paths that are
            % sub-directories to the current remote path are returned, by
            % default.
            %   remotePaths = obj.listRemotePaths() % sub paths of current remote path
            %   remotePaths = obj.listRemotePaths('sortFlag',true); % Could be set to false
            %   remotePaths = obj.listRemotePaths('all',true);      % All paths
            %   remotePaths = obj.listRemotePaths('print',true);  % Print to console
            p = rdtInputParser();
            p.addOptional('all', false, @islogical);
            p.addOptional('print', false, @islogical);

            p.parse(varargin{:});
            all   = p.Results.all;
            print = p.Results.print;

            allPaths = rdtListRemotePaths(obj.configuration, varargin{:});
            
            str = obj.pwrp;
            if all || isempty(str)
                remotePaths = allPaths;
            else
                % Find the paths that contain the current remote path.  These
                % will all be subdirectories.
                subPaths = strfind(allPaths,str);
                lst = find(~cellfun(@isempty,subPaths));
                remotePaths = cell(1,length(lst));
                for ii=1:length(lst)
                    remotePaths{ii} = allPaths{lst(ii)};
                end
            end
            
            % Print to the console
            if print
                
                % Print header line
                if all, hdr = sprintf('\n --- All remote paths ------\n');
                else    hdr = sprintf('\n  -- Sub-paths of [ %s ]---\n',obj.pwrp);
                end
                fprintf('%s',hdr);
                
                % Print list
                for ii=1:length(remotePaths)
                    fprintf('\t#%d:\t\t%s\n',ii,remotePaths{ii});
                end
            end
            
            
        end
        
        function artifacts = listArtifacts(obj, varargin)
            % List artifacts under a remote path.
            %   artifacts = obj.listArtifacts() % remotePath = pwrp()
            %   artifacts = obj.listArtifacts('remotePath', remotePath)
            %   artifacts = obj.listArtifacts('sortField', field); % default is sort by artifactId
            %   artifacts = obj.listArtifacts('print',true);
            %            %  
            % sortField - artifactId by default
            % print     - print a table
            % recursive - By default, only the artifacts in the remote path
            % are returned. If recursive is set to true, the the artifacts
            % in the remote path and sub paths are returned.
            %
            % Example (with defaults shown)
            %   a = obj.listArtifacts('print',false,...
            %                         'type','mat',...
            %                         'remotePath',obj.pwrp,...
            %                         'recursive',false,...
            %                         'sortField','artifactId');
            %
            %  See also: rdtListArtifacts, rdtPrintArtifactTable
            
            parser = rdtInputParser();
            parser.addParameter('remotePath', obj.workingRemotePath, @ischar);
            parser.addParameter('sortField', 'artifactId', @ischar);
            parser.addParameter('recursive',false,@islogical);
            parser.addParameter('print',false,@islogical)
            parser.parse(varargin{:});
            
            remotePath = parser.Results.remotePath;
            sortField  = parser.Results.sortField;
            recursive  = parser.Results.recursive;
            print    = parser.Results.print;
            
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
                
                % Sort the cell arrays of artifacts
                artifacts = rdtSortStructArray([artifactCollection{:}], sortField);
            else
                % list artifacts under the specific path
                artifacts = rdtListArtifacts(obj.configuration, ...
                    remotePath, varargin{:});

                % Sort the artifacts
                artifacts = rdtSortStructArray(artifacts, sortField);

            end
            
            % Find lst of artifacts in the current remote path
            if isempty(artifacts)
                fprintf('\n -- No artifacts found in %s path --\n\n',obj.pwrp);
                return;
            end
            aStr = struct2cell(artifacts);
            aC = squeeze(aStr(5,1,:));   % Get the remote paths into cells
            lst = strcmp(obj.pwrp,aC);
            
            % If not recursive, remove the others, print, return
            if ~recursive
                artifacts = artifacts(lst);
                lst = true(1,length(artifacts));
            end

            if print
                if sum(lst)
                    fprintf('\n  -- Artifacts in Current remote path [ /%s/ ]---\n\n',obj.pwrp);
                    rdtPrintArtifactTable(artifacts(lst));
                end
                if sum(~lst)
                    fprintf('\n  -- Artifacts in subdirectories of remote path [ /%s/ ]---\n\n',obj.pwrp);
                    rdtPrintArtifactTable(artifacts(~lst));
                end
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
            % You must supply the "remotePath" to the artifact. This is
            % like the folder that contains a file, for example the
            % "/path/to/file" in "/path/to/file/foo.txt".  If you omit the
            % remotePath, the value of pwrp() is used.
            %
            % You can supply a "destinationFolder", in which case the file
            % name will be decoded and the file will be placed into the
            % directory you indicate.
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
            %   ( ... 'destinationFolder',fullFolderName) Output file
            
            % We should trap the 'type' argument here and pass it below.
            % BW.
            parser = rdtInputParser();
            vFunc = @(x)(ischar(x) || isstruct(x));
            parser.addRequired('artifactId', vFunc);
            parser.addParameter('remotePath', obj.workingRemotePath, @ischar);
            parser.parse(artifactId, varargin{:});
            
            artifactId = parser.Results.artifactId;
            remotePath = parser.Results.remotePath;
            
            % Adjusted to permit sending in the artifact struct, not just
            % the id slot, as an argument.  This way readArtifact can take
            % an artifact argument.
            if isstruct(artifactId) && isfield(artifactId,'artifactId')
                % We set up the type here automatically
                % It would be possible to just use the URL, I think.
                id   = artifactId.artifactId;
                type = artifactId.type;
                [data, artifact, downloads] = rdtReadArtifact(obj.configuration, ...
                    remotePath, id, 'type',type, varargin{:});
            elseif ischar(artifactId)
                % Ben's original call
                [data, artifact, downloads] = rdtReadArtifact(obj.configuration, ...
                    remotePath, artifactId, varargin{:});
            else
                error('Input structure does not have an artifactId slot.');
            end

            %             [data, artifact, downloads] = rdtReadArtifact(obj.configuration, ...
            %                 remotePath, artifactId, varargin{:});
        end
        
        function [datas, artifacts, downloads] = readArtifacts(obj, pathOrArtifacts, varargin)
            % Read data for multiple artifacts into Matlab.
            %   [datas, artifacts] = obj.readArtifacts() all under pwrp()
            %   obj.readArtifacts(remotePath) remotePath instead of pwrp()
            %   obj.readArtifacts(artifacts) explicit artifact struct array
            
            datas = {};
            artifacts = {};
            
            if nargin < 2 || isempty(pathOrArtifacts)
                % all under pwrp()
                artifacts = obj.listArtifacts();
                [datas, artifacts, downloads] = rdtReadArtifacts(obj.configuration, artifacts, varargin{:});
                
            elseif ischar(pathOrArtifacts)
                % all under remote path
                artifacts = rdtListArtifacts(obj.configuration, pathOrArtifacts);
                [datas, artifacts, downloads] = rdtReadArtifacts(obj.configuration, artifacts, varargin{:});
                
            elseif isstruct(pathOrArtifacts)
                % explicit struct array
                [datas, artifacts, downloads] = rdtReadArtifacts(obj.configuration, pathOrArtifacts, varargin{:});
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
            
            % I think we need a full path to the file.  Maybe we need to
            % check this.
            if exist(file,'file')
                artifact = rdtPublishArtifact(obj.configuration, ...
                    file, remotePath, varargin{:});
            else
                error('The file %s is not found\n');
            end
        end
        
        function artifacts = publishArtifacts(obj, folder, varargin)
            % Publish files in a folder as artifacts to a remote repository.
            %   artifact = obj.publishArtifacts(folder)
            %   ( ... 'remotePath', remotePath) remotePath instead of pwrp()
            %   ( ... 'version', version) version instead of default '1'
            %   ( ... 'type', type) restrict to type
            %
            % The files in "folder" (a full path) will be uploaded to the
            % current remote path in the RdtClient object.  To see the
            % current remote path you can type obj.pwrp or
            % obj.workingRemotePath
            
            parser = rdtInputParser();
            parser.addRequired('folder', @ischar);
            parser.addParameter('remotePath', obj.workingRemotePath, @ischar);
            parser.addParameter('print', false, @islogical);

            parser.parse(folder, varargin{:});
            folder = parser.Results.folder;
            remotePath = parser.Results.remotePath;
            print = parser.Results.print;
            
            artifacts = rdtPublishArtifacts(obj.configuration, ...
                folder, remotePath, varargin{:});
            
            if print
                rdtPrintArtifactTable(artifacts);
            end

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
            parser.addOptional('fancy',false,@islogical);
            parser.parse(varargin{:});
            
            whichUrlOrArtifact = parser.Results.whichUrlOrArtifact;
            
            % Use the fancy browsing method rather than the simple direct
            % one by default.  This is invoked by building a special URL
            % that indicates to the server to call their special interface.
            % In this case, I don't know how to append the
            % whichUrLOrArtifact yet.  Maybe BSH will figure it out.
            if parser.Results.fancy
                % http://52.32.77.154/#browse~vistasoft
                url = sprintf('%s#browse~%s',obj.configuration.serverUrl,obj.configuration.repositoryName);
                web(url, '-browser');
            else
                url = '';
                if isempty(whichUrlOrArtifact)
                    % If there is no argument, then we open the repository URL,
                    % appending the working directory.
                    % open pwrp()
                    version    = '';
                    artifactId = '';
                    fileName   = '';
                    url = rdtBuildArtifactUrl(obj.configuration.repositoryUrl, obj.workingRemotePath, version,artifactId,fileName);
                    
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
