function dest = dirGet(obj,dirName,dest)
% Retrieve all the files in a remote directory
%
% Inputs:
%  dirName:  String defining the remote directory
%  dest:     Destination directory
%
% Example:
%  rd = 
%  rd.dirGet('AFQ/example_sub','/tmp/deleteMe');
% 
%  BW Copyright ISETBIO Team, 2015

% Create a name for the destination directory
% We make a temporary name if one is not supplied.
if notDefined('dest'), dest = tempname; end
if ~exist(dest,'dir'), mkdir(dest); end

% Find the first directory that matches
% I am worried that there might be multiple matches and we won't detect
% them with this logic.
thisD = [];
d = obj.directories;
for ii=1:numel(d)
    if strfind(d{ii},dirName)
        thisD = [thisD, ii];
    end
end
if numel(thisD) > 1, error('Multiple directory matches. %d',thisD); end

% Copy the list of files in the remote directory to the dest directory
fDest = obj.files{thisD};
dString = char(d{ii}(((end-10):end)));
for ii=1:numel(fDest)
    thisF = char(fDest{ii});
    urlString = fullfile(dString,thisF);
    fDest{ii} = fullfile(dest,thisF);
    obj.fileGet(urlString,fDest{ii});
end

end
