function urlsList(obj)
% Print a list of all the files in the rd
%
%  rd.urlsList
%
% Example:
%  rd = rdata;
%  rd.urlsList
%
% HJ/BW ISETBIO Team, Copyright 2015

% Let's make this nicer.

nURL = length(obj.url);
fprintf('\n*** List of urls ***\n\n');
for ii=1:nURL
    fprintf('%s\n',obj.url{ii})
end
