function T = rdtPrintArtifactTable(a)
%% Print a table of the id, type and remote path of an array of artifacts
%
%   T = rdtPrintArtifactTable(artifacts);
%
% Example:
%   rd = RdtClient('isetbio');
%   txt = 'scene1';
%   a = rd.searchArtifacts(txt,'type','jpg');
%   rdtPrintArtifactTable(a);
%   
% See also rdtListRemotePaths, rdtListArtifacts, rdtArtifact
%
% Copyright (c) 2016 RemoteDataToolbox Team

% This code is short but it depends on the structure of the artifact If
% that changes, we may have to change the entries

% Break the artifacts into a cell array of strings
aStr = struct2cell(a);

% These are the strings corresponding to the artifact ID
ID = aStr(1,1,:); ID = squeeze(ID);

% The remote paths
RemPath = aStr(5,1,:);RemPath = squeeze(RemPath);

% The artifact types
Type = aStr(7,1,:);Type = squeeze(Type);

% Here is the table
T = table(ID,Type,RemPath);

% Display it
fprintf('\n***\n%d artifacts \n***\n',length(a));
disp(T);

end