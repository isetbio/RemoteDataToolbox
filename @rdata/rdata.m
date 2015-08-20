classdef rdata < handle
% Constructor a remote data object used for downloading data 
%
%   rd = rdata(varargin);
%
% The rdata object is created to help find and download data from a remote
% site that contains useful test and validation data.
%
% The rdata object serves as a database for helping to read the files on
% the remote data site. It has various methods to help find the files,
% open the web-site, and search for the file urls for downloading.
%
% This object requires that the remote data site have an up-to-date Table
% of Contents stored in the base directory.  That TOC is read and stored
% with the rdata object is created. 
%
% The default remote data site is
%
%   'http://scarlet.stanford.edu/validation/SCIEN/ISETBIO'
%
% Key Methods:
%   .urlfile - rd.urlfile(str) retrieves urls containing the string
%   .webSite - Open the remote web-site in the system browser
%   .set     - 
%   .get     - 
%   .tocURL
%   
%
% Examples (creating the rdata object and loading the TOC):
%    rd = rdata('base','http://scarlet.stanford.edu/validation/SCIEN')
%
%   Open one of the MRI data sites
%    rd = rdata('base','http://scarlet.stanford.edu/validation/MRI/VISTADATA')
%
%   Show the web-site view of the remote data
%    rd.webSite;
%
%   The urls to all the files in the TOC
%    allURLs = rd.urlfile;
%
%   To all the files with the string 'bvecs'
%    url = rd.urlfile('bvecs');
%
%   Use with urlwrite to get a remote file and store it in a local
%   directory
%    url = rd.urlfile('dwi.bvecs')
%    fname = fullfile(rootPath,'local','dwi.bvecs');
%    urlwrite(url,fname);
%
% BW ISETBIO Team, Copyright 2015

properties
    name = 'remotedata' % Name of this object
    base = '';          % URL of base directory with TOC
    directories = {};   % List of the directory names, 1:D
    files = {};         % List of files in each directory
    url = {};           % List of URLs to every file
end

methods (Access = public)

    % Required methods are
    %  constructor, set, get, display
    function obj = rdata(varargin)
        
        if isempty(varargin)
            obj = rdata('base','http://scarlet.stanford.edu/validation/SCIEN');
            return;
        end
        
        % Parameter/value pairs.  
        for ii=1:2:length(varargin)
            obj.set(varargin{ii},varargin{ii+1});
        end
        
        % Read the Table of Contents from the base directory
        obj.tocLoad;
        
        % Create the URLs to each individual file
        obj.urlCreate;
        
    end
    
    function val = get(obj,param,varargin)
        
        % Remove spaces and lower case for parameter argument
        param = ieParamFormat(param);
        
        % Get the requested parameter
        switch(param)
            case 'name'
                % Name of this object
                val = obj.name;
            case 'base'
                % URL to the base directory of the data
                val = obj.base;
            case 'directories'
                % Cell array of directories
                val = obj.directories;
            case 'files'
                % Cell array of the files in each directory
                val = obj.files;
            case 'ndirs'
                val = numel(obj.directories);
            case 'nfiles'
                % Number of files in all the directories
                val = numel(obj.url);
            case 'url'
                % The URLs to every file in the TOC
                val = obj.url;                
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
        % Should this be renamed to urlTOC?
        % Make the url to the table of contents on the remote site
        url = fullfile(obj.base,'TOC.jsn');
    end
    
    function webSite(obj)
        % Open the base address in the system web browser
        web(obj.base,'-browser');
    end
    
end

end

