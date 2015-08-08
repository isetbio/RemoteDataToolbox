function [dest,url] = fileGet(obj,fname,dest)
% Retrieve a single file and place it at destination
% If destination is empty, place it in a temp file
% rd.fileGet('sphere.nii.gz');
%
% BW Copyright ISETBIO Team, 2015

if notDefined('dest'), dest = tempname; end

url = obj.urlfile(fname);

if numel(url) > 1
    error('Multiple files with that name.  No transfer made.');
else
    urlwrite(url{1},dest);
end

end