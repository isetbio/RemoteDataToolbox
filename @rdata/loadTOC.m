function loadTOC(obj,localDir)
% Write the TOC file into a temporary directory

% First check that the directory exists, and if not make it
if notDefined('localDir')
    localDir = fullfile(tempdir,'rdata');
end
if ~exist(localDir,'dir'),  mkdir(localDir); end

% Download the file, and check status
tocFile = fullfile(localDir,'TOC.mat');
url = obj.tocURL;
[~,status] = urlwrite(url,tocFile);
if ~status, error('TOC file not downloaded.'); end

% Load the TOC and put it in the rdata object
load(tocFile,'TOC');
obj.directories = TOC.d;
obj.files = TOC.f;

end
