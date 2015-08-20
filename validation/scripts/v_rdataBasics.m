%% Script to validate basic rdata calls
%
% Running a few informal tests.  Needs to be extended and checked more
% systematically
%
% BW ISETBIO Team, Copyright 2015


%% Default base directory is ISETBIO
rd = rdata;    % Runs loadTOC and urlCreate

% Just dump it out to have a look
rd

rd.webSite;

% Have a look at the files
rd.fileList

%% Try another base directory
rd = rdata('base','http://scarlet.stanford.edu/validation/SCIEN/RGB');

rd.dirList('LStryer')

% Look at the nice picture
img = rd.imageRead('twoBirds.jpg');
vcNewGraphWin; imshow(img);

%% Load the MRI directory
rd = rdata('base','http://scarlet.stanford.edu/validation/MRI/VISTADATA');

% Files that contain bvecs
lst  = rd.urlFile('bvecs')
dest = rd.fileGet(lst{1})

rd.dirList('T1andMesh')

%% END
