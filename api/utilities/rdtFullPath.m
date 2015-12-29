function fullPath = rdtFullPath(pathParts, varargin)
%% Build a full path string from a list of parts.
%
% fullPath = rdtFullPath(pathParts) builds a path string from the given
% cell array of path parts, with parts delimited by '/'.
%
% Empty path parts will cause extra delimiters to be inserted.
%
% For example, rdtFullPath({'', 'foo', 'bar'}) would build up to the
% path "/foo/bar".
%
% converted = rdtConvertPathStyle(... 'separator', separator) uses the
% given separator character instead of the default '/'.
%
% fullPath = rdtFullPath( ... 'trimLeading', trimLeading) obeys the
% optional trimLeading flag.  When trimLeading is true, an empty leading
% path part will be ignored.
%
% fullPath = rdtFullPath( ... 'trimTrailing', trimTrailing) obeys the
% optional trimTrailing flag.  When trimTrailing is true, an empty trailing
% path part will be ignored.
%
% For example, rdtFullPath({'', 'foo', 'bar', ''}, 'separator', '.',
% 'trimLeading', true, 'trimTrailing, true) would build up to the path
% "foo.bar".
%
% fullPath = rdtFullPath(pathParts, varargin)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('pathParts', @iscellstr);
parser.addParameter('separator','/', @(sep) ischar(sep) && 1 == numel(sep));
parser.addParameter('trimLeading', false, @islogical);
parser.addParameter('trimTrailing', false, @islogical);
parser.parse(pathParts, varargin{:});
pathParts = parser.Results.pathParts;
separator = parser.Results.separator;
trimLeading = parser.Results.trimLeading;
trimTrailing = parser.Results.trimTrailing;

if isempty(pathParts)
    fullPath = '';
    return;
end

%% Trim leading or trailing parts?
if trimLeading && isempty(pathParts{1})
    first = 2;
else
    first = 1;
end

nPathParts = numel(pathParts);
if trimTrailing && isempty(pathParts{nPathParts})
    last = nPathParts -1;
else
    last = nPathParts;
end

pathParts = pathParts(first:last);

if isempty(pathParts)
    fullPath = '';
    return;
end

%% Print parts and delimiter.

% We need to handle the case in which the first string is http:, in which
% case we need to have two separators (//) instead of just one.  So we add
% a /.
if strcmp(pathParts{1},'http:'), pathParts{1}='http:/'; end
withExtraSeparator = sprintf(['%s' separator], pathParts{:});
fullPath = withExtraSeparator(1:end-1);

% enforce char class in case empty matrix
if isempty(fullPath)
    fullPath = '';
    return;
end
