function pathParts = rdtPathParts(original, varargin)
%% Break a path string into parts delimited by a separator character.
%
% parts = rdtPathParts(original) breaks the given original path into parts
% delimited by filesep().
%
% If the original path stirng contains a leading or trailing separator,
% an empty leading or trailing empty path part will be included.
%
% For example, rdtPathParts('/foo/bar) would build up  break into three
% parts: '', 'foo', and 'bar'.
%
% converted = rdtConvertPathStyle(... 'separator', separator) uses the
% given separator character instead of the default filesep().
%
% Returns a cell array containing the broken up path parts.
%
% See also rdtFullPath filesep
%
% pathParts = rdtPathParts(original, varargin)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('original', @ischar);
parser.addParameter('separator', filesep(), @(sep) ischar(sep) && 1 == numel(sep));
parser.parse(original, varargin{:});
original = parser.Results.original;
separator = parser.Results.separator;

if isempty(original)
    pathParts = {};
    return;
end

% split up the original
pathParts = strsplit(original, separator, ...
    'DelimiterType', 'Simple', ...
    'CollapseDelimiters', true);
