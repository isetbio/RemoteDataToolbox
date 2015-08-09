function [dest,url] = fileGet(obj,str,dest)
% Retrieve a single file and place it at dest
%
%    [dest,url] = rd.fileGet(str,dest)
%
% If destination is empty, place it in a temp directory, such as
% /tmp/rdata/<filename>
%
% Example:
%  rd = rdata;  % Default is SCIEN/ISETBIO
%  [dest,url] = rd.fileGet('EurasianFemale_Office.mat')
%
% BW Copyright ISETBIO Team, 2015

% Find the urls that match the string.  THere should be one.
url = obj.urlFile(str);

if numel(url) > 1
    error('Multiple files match the string %s\n.  No transfer.',str);
elseif isempty(url)
    error('No files match the string %s\nNo transfer', str);
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