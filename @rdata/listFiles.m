function val = listFiles(rd,dirName)
% List all the directories at the remote data site
%
%   rd.listFiles(dirName)
%
% The dirName must contain a string that matches one of the directories
%
% Example:
%  rd = rdata('base','http://scarlet.stanford.edu/validation/SCIEN/RGB');
%  rd.listFiles('LStryer')
%  rd.listFiles('Stryer')
%
% BW Copyright ISETBIO Team, 2015

dNames = rd.directories;
for ii=1:numel(dNames), [~,dNames{ii}] = fileparts(dNames{ii}); end
lst = strfind(dNames,dirName);
if isempty(lst)
    error('No match found for %s\n',dirName);
end

% Find the first match and print it and return.
% Maybe we should check for more matches ...?
if nargout == 0
    for ii=1:numel(lst)
        if ~isempty(lst{ii})
            fprintf('\nDirectory: %s\n',rd.directories{ii});
            for jj=1:numel(rd.files{ii})
                fprintf('\t%s\n',char(rd.files{ii}(jj)));
            end
            return;
        end
    end
    fprintf('\n');
else
    for ii=1:numel(lst)
        val = sprintf('Files in directory %s\n',dNames{ii});
        for jj=1:numel(rd.files{ii})
            val = addText(val,sprintf('\t %s\n',char(rd.files{ii}(jj))));
        end
    end
end

end


