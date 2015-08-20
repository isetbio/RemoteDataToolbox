function val = urlFile(obj,str)
% Returns a cell array of urls that contain the string
%
%  urlList = obj.urlFile(str)
%
% (BW) Copyright ISETBIO Team, 2015

if notDefined('str'), val = obj.url; return; end

% Find the urls that contain the string
urlstrings = obj.url;
s = strfind(urlstrings,str);

% There must be a better way to do this
lst = [];
for ii=1:numel(s),
    if ~isempty(s{ii}), lst = [lst,ii]; end
end

% Build the list of urls
val = cell(numel(lst),1);
for ii=1:numel(lst),  val{ii} = urlstrings{lst(ii)}; end

end
