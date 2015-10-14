%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Search a folder and its parents to find a file with the given name.
%   @param fileName the name of a file to look for
%   @param folder path where to start looking for @a fileName
%
% @details
% Recursively searches @a folder and its parent folder for the given @a
% fileName. If @a folder is omitted, uses pwd().  Returns as soon as @a
% fileName is found, or when the file system root is reached.
%
% @details
% Returns the full path to the given @a fileName, or '' if no such file was
% found.
%
% @details
% Also returns a cell array containing all of the folders that were
% searched.
%
% @details
% Usage:
%   [filePath, foldersSearched] = rdtSearchParentFolders(fileName, folder)
%
% @ingroup utilities
function [filePath, foldersSearched] = rdtSearchParentFolders(fileName, folder)

if nargin < 2 || isempty(folder)
    folder = pwd();
end

filePath = '';
foldersSearched = {};

while isempty(filePath)
    % grow the short list of searched folders as we go
    foldersSearched{end+1} = folder; %#ok<AGROW>
    
    % does the file exist in this folder?
    candidatePath = fullfile(folder, fileName);
    if exist(candidatePath, 'file') && ~exist(candidatePath, 'dir')
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
