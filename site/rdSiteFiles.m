function TOC = rdSiteFiles(baseDir, saveFlag) 
% Create mat-file and JSON file summarizing contents of a remote directory
%
% The struct and file sit in the base directory.  These files can be
% downloaded to faciliate finding files in other routines.
%
% Uses the tools in iset-admin to 
%
%   (a) Walk the directory tree and identify all directories
%   (b) Find the files with specific extensions
%   (c) Make a struct containing the directories with files with these
%   extensions
%   
% We can download the struct using urlread and when you try to find a file
% with some name find its location from the struct.
%
% We save the directory information in a JSON file, also, so that the list
% of files can be viewed with a browser.
%
% Example
%  baseDir = '/wandellfs/data/validation/SCIEN/ISETBIO';
%  TOC = rdSiteFiles(baseDir);
%  chdir(baseDir); save('TOC','TOC');
%
%  saveFlag = true;
%  rdSiteFiles(baseDir,saveFlag);
%
% BW ISETBIO Team, Copyright 2015

%% Walk the directory
if notDefined('saveFlag'), saveFlag = true; end

curDir = pwd;

chdir(baseDir);

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

    % fprintf('Checking directory %s\n',pNames{ii});
    
    % Find the mat-files
    fNames = ibNewFiles(pNames{ii}, fNames, 'mat');

    % Find the jpg-files
    fNames = ibNewFiles(pNames{ii}, fNames,'jpg');

    % Find the jpg-files
    fNames = ibNewFiles(pNames{ii},fNames, 'png');
    
    if ~isempty(fNames)
        TOC.d{cnt} = pNames{ii};
        TOC.f{cnt} = fNames;
        cnt = cnt + 1;
        nFiles = nFiles + length(fNames);
    end
    
end

fprintf('Found %d files in %d directories\n',nFiles,length(TOC.d));

if saveFlag
    save('TOC','TOC');
    fprintf('Saved new TOC mat-file in %s\n',baseDir)
    
    savejson('TOC',TOC,'TOC.jsn');
    fprintf('Saved new TOC json-file in %s\n',baseDir)

end

chdir(curDir);

end


function fNames = ibNewFiles(updateDir,fNames, ext)
% Add files in UpdateDir with ext to the fNames list
%

newFiles = dir(fullfile(updateDir,['*.',ext]));

if ~isempty(newFiles)
    % fprintf('New files found in %s\n',updateDir);
    
    newNames = cell(length(newFiles),1);
   
    for ii=1:length(newFiles)
        newNames{ii} = newFiles(ii).name;
    end
    
    if isempty(fNames), fNames = newNames;
    else fNames = cat(newNames,fNames);
    end

end

end




