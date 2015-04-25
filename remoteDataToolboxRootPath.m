% Function to return the path to the root of the remoteDataToolbox
%

function rootPath=remoteDataToolboxRootPath()
% This function must reside in the directory at the base of the remoteDataToolbox.
% It is used to determine the location of various sub-directories.
% 
% Example:
%   fullfile(remoteDataToolboxRootPath,'external')

    rootPath = which(mfilename);
    [rootPath,~,~]=fileparts(rootPath);
end