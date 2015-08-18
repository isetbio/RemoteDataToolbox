function urlCreate( rd )
% Create the urls to each file in the Table of Contents (TOC)
%
% The url strings are created when the remote data object is created.  The
% urls are stored as a cell array in the obj.url slot.
%
% BW, ISETBIO Team, Copyright 2015

% Full url to every one of the remote files
nDir   = rd.get('n dirs');
nFiles = rd.get('n files');
val = cell(nFiles,1);
cnt = 1;

[~,baseName] = fileparts(rd.base);
nBaseName = length(baseName);
for ii=1:nDir
    % rd.directories{ii}, ii
    % If there is only one file, then obj.files{ii} is a string, not a cell
    % array 
    if iscell(rd.files{ii})
        for jj=1:numel(rd.files{ii})
            % Build the URL from the parts We remove the part
            % of the directory that overlap with the URL.
            % Maybe this should be done when we create the TOC.
            start = strfind(rd.directories{ii},baseName);
            
            % Make the URLs for
            %  this directory (ii)
            %  and the files in this directory, obj.file{ii}(jj)
            val{cnt} = char(fullfile(rd.base,rd.directories{ii}((start+length(baseName)):end),rd.files{ii}(jj)));
            cnt = cnt+1;
        end
    else
        % Since it is not a cell, it must be a string, do this
        start = strfind(rd.directories{ii},baseName);
        val{cnt} = fullfile(rd.base,rd.directories{ii}((start+nBaseName):end),rd.files{ii});
        cnt = cnt+1;
    end
end

rd.url = val;

end

