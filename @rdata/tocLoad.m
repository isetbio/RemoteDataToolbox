function tocLoad(obj,localDir)
% Write the TOC file into a temporary directory
%
% We are using JSON files now rather than MAT files in the hopes that we
% will have a general php or python script that runs on the remote
% directory nightly to update the directory TOC.
%
% HJ/BW ISETBIO Team Copyright 2015

% First check that the directory exists, and if not make it
if notDefined('localDir')
    localDir = fullfile(tempdir,'rdata');
end
if ~exist(localDir,'dir'),  mkdir(localDir); end

% Download the file, and check status
tocFile = fullfile(localDir,'TOC.jsn');
url = obj.tocURL;
[~,status] = urlwrite(url,tocFile);
if ~status, error('TOC not downloaded at \n%s\n',url); end

% Load the TOC and put it in the rdata object
jsn = loadjson(tocFile); 
TOC = jsn.TOC;

if iscell(TOC.d),     obj.directories = TOC.d;
else                  obj.directories = {TOC.d};
end

% Should we allow the files to be strings? Or should we force them to be
% cells too?
if iscell(TOC.f), obj.files = TOC.f;
else              obj.files = {TOC.f};
end

end
