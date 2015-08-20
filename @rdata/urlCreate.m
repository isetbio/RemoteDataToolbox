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

if nDir == 1
    start = strfind(rd.directories{1},baseName);
    % We have to separate the case where there is one directory
    nFiles = length(rd.files);
    for ii=1:nFiles
        val{cnt} = char(fullfile(rd.base,rd.directories{1}((start+nBaseName):end),rd.files{ii}));
        cnt = cnt+1;
    end
else
    % Lots of directories, so the rd.files{ii} are all cell arrays
    for ii=1:nDir
        start = strfind(rd.directories{ii},baseName);
        % If there is only one file, then obj.files{ii} is a string, not a cell
        % array.  Otherwise rd.files{ii} is a cell array of the files for the
        % iith directory.
        nFiles = numel(rd.files{ii});
        if nFiles == 0
            % Do nothing
        elseif nFiles ==1
            val{cnt} = char(fullfile(rd.base,rd.directories{ii}((start+nBaseName):end),rd.files{ii}));
            cnt = cnt+1;
        else
            for kk=1:nFiles
                % Build the URL from the parts We remove the part
                % of the directory that overlap with the URL.
                % Maybe this should be done when we create the TOC.
                
                % Make the URLs for
                %  this directory (ii)
                %  and the files in this directory, obj.file{ii}(jj)
                val{cnt} = char(fullfile(rd.base,rd.directories{ii}((start+nBaseName):end),rd.files{ii}(kk)));
                cnt = cnt+1;
            end
        end
    end
end


    %     for jj=1:numel(rd.files{ii})
    %         if iscell(rd.files{ii})
    %             for kk=1:numel(rd.files{ii})
    %                 % Build the URL from the parts We remove the part
    %                 % of the directory that overlap with the URL.
    %                 % Maybe this should be done when we create the TOC.
    %
    %                 % Make the URLs for
    %                 %  this directory (ii)
    %                 %  and the files in this directory, obj.file{ii}(jj)
    %                 val{cnt} = char(fullfile(rd.base,rd.directories{ii}((start+length(baseName)):end),rd.files{ii}{kk}));
    %                 cnt = cnt+1;
    %             end
    %         else  %It is a string, so just add it
    %             % Since it is not a cell, it must be a string,
    %             % Its parent is the cell array.  So we loop on that
    %             val{cnt} = char(fullfile(rd.base,rd.directories{ii}((start+nBaseName):end),rd.files{ii}));
    %             cnt = cnt+1;
    %         end
    %     end
    % end

rd.url = val;

end

