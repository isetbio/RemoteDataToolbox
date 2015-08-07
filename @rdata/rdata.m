classdef rdata < handle
% Constructor a remote data object used for downloading data 
%
%   rd = rdata(varargin);
%
%
% Examples:
%
%
% BW ISETBIO Team, Copyright 2015

properties
    name = 'remotedata'
    base = 'http://scarlet.stanford.edu/validation/ISETBIO';
    directories = {};   % List of the directory names, 1:D
    files = {};         % List of files in each directory
end

methods (Access = public)

    % Required methods are
    %  constructor, set, get, display
    function obj = rdata(varargin)
        
        if isempty(varargin)
            rdata('name','remotedata','base','http://scarlet.stanford.edu/validation/ISETBIO');
        end
        
        % Read the TOC from the base directory
        urlread(fullfile(obj.base,'TOC.mat');
        
        % Parameter/value pairs
        for ii=1:2:length(varargin)
            obj.set(varargin{ii},varargin{ii+1});
        end
        
    end
    
    function val = get(obj,param,varargin)
        
        % Remove spaces and lower case for parameter argument
        param = ieParamFormat(param);
        
        % Get the requested parameter
        switch(param)
            case 'name'
                val = obj.name;
            case 'base'
                val = obj.base;
            case 'directories'
                val = obj.directories;
            case 'files'
                val = obj.files;
            case 'ndirs'
                val = numel(obj.directories);
            case 'nfiles'
                val = 0;
                nDirs = obj.get('ndirs');
                for ii=1:nDirs
                    nFiles = nFiles + numel(obj.files{ii});
                end
            case 'fileurl'
                % Full url to all of the files
                nDir =obj.get('n dirs');
                nFiles = obj.get('n files');
                val = cell(nFiles,1);
                cnt = 1;
                for ii=1:nDir
                    for jj=1:numel(obj.files{ii})
                        val{cnt} = fullfile(obj.base,obj.directories{ii},obj.files{ii});
                        cnt = cnt+1;
                    end
                end                   
            otherwise
                error('Unknown parameter %s\n',param);
        end
        
    end
    
    function set(obj,param,val,varargin)
        % Set the rdata core properties
        
        % Remove spaces and lower case
        param = ieParamFormat(param);
        
        % Set
        switch param
            case 'name'
                obj.name = val;
            case 'base'
                obj.base = val;
            case 'directories'
                obj.directories = val;
            case 'files'
                obj.files = val;
            otherwise
                error('Unknown parameter %s\n',param);
        end
    end
    
    function display(obj,varargin)
        fprintf('\nRemote data object\n');
        fprintf('\tname: %s\n',obj.name);
        fprintf('\tbase: %s\n',obj.base);
        fprintf('\t%d directories\n',numel(obj.directories));
        fprintf('\t%d files\n',obj.get('nfiles'));
    end
    
end

end

    
% switch f
%     
%     case 'ls'
%         % dirList = rdata('ls',remote, extension);
%         if ~isempty(varargin), pattern = varargin{1};
%         else pattern = '.mat';
%         end
%         
%         % Read and parse html string
%         % Some day we might pass this as an argument
%         p    = '<a[^>]*href="(?<link>[^"]*)">(?<name>[^<]*)</a>';
%         
%         % str  = webread(webdir);
%         str  = urlread(webdir);
%         name = regexp(str, p, 'names');
% 
%         %% Filter by user input pattern
%         if ~isempty(pattern)
%             indx = arrayfun(@(x) ~isempty(strfind(x.name, pattern)), name);
%             nfiles = sum(indx);
%             if nfiles == 0, warning('No files match pattern: %s',pattern);
%             else
%                 % Copy the matching patterns
%                 names = cell(nfiles,1);
%                 cnt = 1;
%                 for ii=find(indx)
%                     names{cnt} = name(ii).name;
%                     cnt = cnt+1;
%                 end
%             end
%         end
%         val = names;
%         
%     case 'cd'
%         % rdata('cd',remote)
%         setpref('ISET','remote',remote);
%         val = remote;
%         
%     case 'get'
%         % outName = rdata('get',remote,fname);
%         rname = fullfile(webdir,varargin{1});
%         oname = tempname;
%         [val,status] = urlwrite(rname,oname);
%         if ~status,  error('File get error.\n'); end
%         
%     case 'put'
%         % NYI
%         error('Put not yet implemented');
%         
%     case 'readimage'
%         % rdata('read image', remote, fname);
%         if isempty(varargin), error('remote file name required'); end
%         
%         rname = fullfile(webdir,varargin{1});
%         val = imread(rname);
%         
%     case 'loaddata'
%         % rdata('load data',remote,fname,variable)
%         if isempty(varargin), error('remote data file name required'); end
%         
%         rname = fullfile(webdir,varargin{1});
%         oname = tempname; oname = [oname,'.mat'];
%         [oname, status] = urlwrite(rname,oname);
%         if ~status,  error('Load data error.\n'); end
%         
%         val = load(oname);
%         if length(varargin) == 2
%             eval(['val = val.',varargin{2},';']);
%         end
% 
%     otherwise
%         error('Unknown function %s\n',func);
% end

