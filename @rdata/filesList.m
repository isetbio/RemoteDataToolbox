function filesList(obj)
% Print a list of all the files in the rd
%
%  rd.filesList
%
% Example:
%  rd = rdata;
%  rd.filesList
%
% HJ/BW ISETBIO Team, Copyright 2015

% Let's make this nicer.

nDirs = length(obj.directories);
for ii=1:nDirs
    fprintf('\n*** %s\n',obj.directories{ii})
    nFiles = length(obj.files{ii});
    fprintf('\n')
    if iscell(obj.files{ii});
        for jj=1:nFiles
            fprintf('%s\n',char(obj.files{ii}{jj}))
        end
    else
        fprintf('%s\n',obj.files{ii});
    end
end
