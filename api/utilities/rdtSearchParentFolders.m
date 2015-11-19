function [filePath, foldersSearched] = rdtSearchParentFolders(fileName, folder)
%% Search a folder and its parents to find a file with the given name.
%
% [filePath, foldersSearched] = rdtSearchParentFolders(fileName) searches
% pwd() and its parent folders for a file with the given fileName.  Returns
% as soon as such a file is found, or the file system root is reached.
%
% [filePath, foldersSearched] = rdtSearchParentFolders(fileName, folder)
% does the same thing, starting at the given folder instead of pwd().
%
% Returns the full path to the given fileName, or '' if no such file was
% found.  Also returns a cell array containing all of the folders that were
% searched.
%
% See also pwd
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('fileName', @ischar);
parser.addOptional('folder', pwd(), @ischar);
parser.parse(fileName, folder);
fileName = parser.Results.fileName;
folder = parser.Results.folder;

filePath = '';
foldersSearched = {};

while isempty(filePath)
    % grow the short list of searched folders as we go
    foldersSearched{end+1} = folder; %#ok<AGROW>
    
    % does the file exist in this folder?
    candidatePath = fullfile(folder, fileName);
    if ~isempty(dir(candidatePath))
        filePath = candidatePath;
        return;
    end
    
    parentFolder = fileparts(folder);
    if isempty(parentFolder) || strcmp(parentFolder, folder)
        % ran out of parent folders
        return;
    end
    
    % continue searching parent
    folder = parentFolder;
end
