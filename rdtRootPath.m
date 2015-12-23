function rootpath = rdtRootPath()
%% rdtRootPath returns the path to the root remoteDataToolbox directory
%
% This function must reside in the main directory containing the remote
% data toolbox package.
%
% This helps with loading and saving files for the rdt toolbox.

rootpath = which('rdtRootPath');

rootpath = fileparts(rootpath);

return