function urlCreate( obj )
% Create the urls to each file in the Table of Contents (TOC)
%
% The url strings are created when the remote data object is created.  The
% urls are stored as a cell array in the obj.url slot.
%
% BW, ISETBIO Team, Copyright 2015

% Full url to every one of the remote files
nDir   = obj.get('n dirs');
nFiles = obj.get('n files');
val = cell(nFiles,1);
cnt = 1;

[~,nBasechars] = fileparts(obj.base);
for ii=1:nDir
    % If there is only one file, then obj.files{ii} is a string, not a cell
    % array 
    if iscell(obj.files{ii})
        for jj=1:numel(obj.files{ii})
            % Build the URL from the parts We remove the part
            % of the directory that overlap with the URL.
            % Maybe this should be done when we create the TOC.
            start = strfind(obj.directories{ii},nBasechars);
            
            % Make the URLs for
            %  this directory (ii)
            %  and the files in this directory, obj.file{ii}(jj)
            val{cnt} = char(fullfile(obj.base,obj.directories{ii}((start+length(nBasechars)):end),obj.files{ii}(jj)));
        end
    else
        % Since it is a string, do this
        start = strfind(obj.directories{ii},nBasechars);
        val{cnt} = fullfile(obj.base,obj.directories{ii}((start+length(nBasechars)):end),obj.files{ii});
    end
    cnt = cnt+1;
end

obj.url = val;

end

