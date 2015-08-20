function img = imageRead(obj,str)
% Read image data from the remote repository
%
%   rd.imageRead(fname)
%
% Example:
%  rd = rdata('base','http://scarlet.stanford.edu/validation/SCIEN');
%  rd.webSite;
%  img = rd.imageRead('rocksWater'); imshow(img)
%  
% BW ISETBIO Team, Copyright 2015

% Find the urls that match the string.  There should be one.
url = obj.urlFile(str);

if numel(url) > 1
    error('Multiple files match the string %s.\n',str);
elseif isempty(url)
    error('No files match the string %s.\n', str);
else
    img = imread(url{1});
end

end
