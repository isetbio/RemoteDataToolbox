function TOC = rdSiteTOC(baseDir,saveFlag) 
% Make MATLAB struct and JSON file describing remote files
%
% This script is intended to be run at a data site.  Its purpose is to
% create the Table of Contents (TOC) of the data in the remote site
% directories. The remote data handling will work by using this file as a
% database structure.  Utility functions will be written assuming access to
% this object.
%
% The TOC can be created from any base directory, in principle. The first
% case we are working out is for SCIEN/ISETBIO.  We can remove this comment
% after we work on other cases.
%
% Inputs
%  baseDir:  This is the root directory.  Files below this list will be
%    catalogued.  At present, we are limiting the file types (e.g.,
%    excluding files with a .txt extension or a .php extensions).  Not sure
%    how to handle this in the future.
%
% Returns
%  TOC - A structure containing the files and directories in
%        various forms that can be searched conveniently by the rdata object.
%
% Uses the tools in RemoteDataToolbox to 
%
%   (a) Walk the directory tree and identify all directories (dirwalk)
%   (b) Find the files with specific extensions 
%   (c) Make a struct containing the directories with files with these
%   extensions
%   
% We use the remote data object (rdata) to download the struct. There is a
% function (rd.loadTOC) that uses urlread and to locate the TOC and put it
% in the rdata object.
%
% We are considering saving the directory information in a JSON file,
% rather than a mat-file, so that the TOC can be viewed with a browser.
%
% Example
%  baseDir = '/wandellfs/data/validation/SCIEN/ISETBIO';
%  TOC = rdSiteTOC(baseDir);
%  chdir(baseDir); save('TOC','TOC');
%
%  baseDir = '/wandellfs/data/validation/MRI/VISTADATA';
%  TOC = rdSiteTOC(baseDir);
%  chdir(baseDir); save('TOC','TOC');
%
% BW ISETBIO Team, Copyright 2015

%% Consider whether we want to keep the rd object in prefs ...
%
% if ispref('ISETBIO','remote')
%     remote = getpref('ISETBIO','remote');
% else
%     remote.host = 'http://scarlet.stanford.edu';
%     remote.directory = fullfile('validation','SCIEN','ISETBIO');
%     remote.base = fullfile(remote.host,remote.directory);
%     setpref('ISETBIO','remote',remote);
% end

%% Walk the directory
curDir = pwd;
chdir(baseDir);

if notDefined('saveFlag'), saveFlag = true; end

% Directory Path names (pNames)
% Directories within each path (dNames)
% File names within each path (fNames)
pNames = dirwalk(baseDir);

nDirs = length(pNames);
nFiles = 0;
TOC = [];
cnt = 1;
for ii=1:nDirs
    
    fNames = [];

    fprintf('Checking directory %s\n',pNames{ii});
    
    % For VISTADATA
    if strfind(baseDir,'MRI')
        fNames = rdNewFiles(pNames{ii},fNames, 'gz');
        fNames = rdNewFiles(pNames{ii},fNames, 'tgz');
        fNames = rdNewFiles(pNames{ii},fNames, 'bvals');
        fNames = rdNewFiles(pNames{ii},fNames, 'bvecs');
    elseif strfind(baseDir,'SCIEN')
        fNames = rdNewFiles(pNames{ii}, fNames, 'mat');
        fNames = rdNewFiles(pNames{ii}, fNames,'jpg');
        fNames = rdNewFiles(pNames{ii},fNames, 'png');
    end
    
    % Create a summary
    if ~isempty(fNames)
        TOC.d{cnt} = pNames{ii};
        TOC.f{cnt} = fNames;
        cnt = cnt + 1;
        nFiles = nFiles + length(fNames);
    end
    
end

fprintf('Found %d files in %d directories\n',nFiles,length(TOC.d));
if saveFlag
    fprintf('\n**Saving Matlab file TOC.mat and json file TOC.jsn\n');
    save('TOC','TOC');
    savejson('TOC',TOC,'TOC.jsn');
end
chdir(curDir);

end


function fNames = rdNewFiles(updateDir,fNames, ext)
% Add files from updateDir with ext to fNames
%

newFiles = dir(fullfile(updateDir,['*.',ext]));

if ~isempty(newFiles)
    % fprintf('New files found in %s\n',updateDir);
    
    newNames = cell(length(newFiles),1);
   
    for ii=1:length(newFiles)
        newNames{ii} = newFiles(ii).name;
    end
    
    if isempty(fNames), fNames = newNames;
    else
        % The names are kept in the rows, so the cell array is N x 1
        fNames = vertcat(newNames,fNames);
    end

end

end




