function [dest,url] = fileGet(obj,str,dest)
% Retrieve a single file and place it at destination
% If destination is empty, place it in a temp file
% rd.fileGet('sphere.nii.gz');
%
% BW Copyright ISETBIO Team, 2015

% Find the urls that match the string.  THere should be one.
url = obj.urlFile(str);

if numel(url) > 1
    error('Multiple files match the string %s\n.  No transfer.',str);
else
    % We have a single match to the string.
    if ~exist('dest','var') || isempty(dest)
        % No destination file name sent.  So create one that matches the
        % file name of the URL.
        [~,n,e] = fileparts(url{1});
        dest = fullfile(tempdir,'rdata',[n,e]);
    end
    urlwrite(url{1},dest);
end

end