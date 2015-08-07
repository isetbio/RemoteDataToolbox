classdef rdata < handle
% Constructor a remote data object used for downloading data 
%
%   rd = rdata(varargin);
%
%
% Examples:
%  Default with ISETBIO case
%    rd = rdata;
%    rd.webSite;
%    rd.set('name','new name'); rd
%
%   Same
%    rd = rdata('base','http://scarlet.stanford.edu/validation/SCIEN/ISETBIO');
%    rd
%
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
        
        % Read the TOC from the base directory
        obj.loadTOC;
        
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
    
    function url = tocURL(obj)
        url = fullfile(obj.base,'TOC.mat');
    end
    
    function webSite(obj)
        % Open the base address in the system web browser
        web(obj.base,'-browser');
        
    end
    
    function loadTOC(obj)
        % Write the TOC file into the isetbioRoot/local directory
        
        localDir = fullfile(isetbioRootPath,'local');
        if ~exist(localDir,'dir'),  mkdir(localDir); end
        
        tocFile = fullfile(localDir,'TOC.mat');
        url = obj.tocURL;
        urlwrite(url,tocFile);
        load(tocFile,'TOC');
        obj.directories = TOC.d;
        obj.files = TOC.f;
    end
    
        
end

end

