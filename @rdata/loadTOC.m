function loadTOC(obj)
% Write the TOC file into the isetbioRoot/local directory

% First check that the directory exists, and if not make it
localDir = fullfile(isetbioRootPath,'local');
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
