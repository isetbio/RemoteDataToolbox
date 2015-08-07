classdef rdata < handle
% Constructor a remote data object used for downloading data 
%
%   rd = rdata(varargin);
%
% The rdata object is created to help find and download data from a remote
% data site that contains useful test and validation data.
%
% The rdata object serves as a little database for helping to read the
% files on the remote data site. It has various functions to help find the
% files, open the web-site, and search for files.
%
% For this object to work, the remote data site must have an up-to-date
% Table of Contents stored in the base directory.  That file is read and
% stored.  The rdata object helps with searching through that site and
% getting files stored at the site.
%
% Examples (creating the rdata object and loading the TOC):
%  Default with ISETBIO case
%    rd = rdata;
%    rd.set('name','new name'); rd
%
%   Same
%    rd = rdata('base','http://scarlet.stanford.edu/validation/SCIEN/ISETBIO');
%    rd
%
%   Open one of the MRI data sites
%    rd = rdata('base','http://scarlet.stanford.edu/validation/MRI/VISTADATA');
%    rd
%
%   Show the web-site view of the remote data
%    rd.webSite;
%
%    allURLs = rd.get('file url');
%   
% BW ISETBIO Team, Copyright 2015

properties
    name = 'remotedata'
    base = 'http://scarlet.stanford.edu/validation/SCIEN/ISETBIO';
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
        
        % Parameter/value pairs.  
        for ii=1:2:length(varargin)
            obj.set(varargin{ii},varargin{ii+1});
        end
        
        % Read the Table of Contents from the base directory
        obj.loadTOC;
        
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
                    val = val + numel(obj.files{ii});
                end
            case 'fileurl'
                % Full url to every one of the remote files
                nDir   = obj.get('n dirs');
                nFiles = obj.get('n files');
                val = cell(nFiles,1);
                cnt = 1;
                for ii=1:nDir
                    for jj=1:numel(obj.files{ii})
                        % Build the URL from the parts
                        % First, there is an overlap with the directory and
                        % the base URL.  We can't have it in there twice,
                        % so we remove the part of the directory that
                        % overlaps with the URL.  Maybe this should be done
                        % when we create the TOC.
                        [~,n]=fileparts(obj.base);
                        start = strfind(obj.directories{ii},n);
                        
                        % For this directory (ii), and then the jj files in
                        % this directory, obj.file{ii}(jj) ...
                        val{cnt} = fullfile(obj.base,obj.directories{ii}((start+length(n)):end),obj.files{ii}(jj));
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
    
    function url = tocURL(obj)
        % Make the url to the table of contents on the remote site
        url = fullfile(obj.base,'TOC.mat');
    end
    
    function webSite(obj)
        % Open the base address in the system web browser
        web(obj.base,'-browser');
    end
    
    function loadTOC(obj)
        % Write the TOC file into the isetbioRoot/local directory
        
        % First check that the directory exists, and if not make it
        localDir = fullfile(isetbioRootPath,'local');
        if ~exist(localDir,'dir'),  mkdir(localDir); end
        
        % Download the file, and check status
        tocFile = fullfile(localDir,'TOC.mat');
        url = obj.tocURL;
        [~,status] = urlwrite(url,tocFile);
        if ~status, error('TOC file not downloaded.'); end
        
        % Load the TOC and put it in the rdata object
        load(tocFile,'TOC');
        obj.directories = TOC.d;
        obj.files = TOC.f;
    end
    
        
end

end

