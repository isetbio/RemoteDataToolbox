function [selector, structArray] = rdtFilterStructArray(structArray, fieldName, fieldValue, varargin)
%% Filter a struct array, passing elements that match a given field value.
%
% structArray = rdtFilterStructArray(structArray, fieldName, fieldValue)
% filters the elements of the given structArray, passing only those
% elements where the given fieldName contains a value that matches the
% given fieldValue.
%
% structArray = rdtSearchArtifacts( ... 'matchStyle', matchStyle) uses the
% given matchStyle to determine whether values match.  Valid values for
% matchStyle are:
%   - 'exact' -- (default) compare by built-in equals()
%   - 'prefix' -- pass when fieldValue is a prefix of each field value
%   - function_handle -- custom function handle for comparison.  The given
%   function must accept two arguments and return true iff they "match".
%   For example, myCustomMatcher = @(a,b) ge(a, b).
%
% Returns a logical matrix with the same size as the given structArray,
% true where elements passed the matching filter.  Also returns a copy of
% the given structArray with only those elements that passed.
%
% Combine the logical results of multiple calls to rdtFilterStructArray()
% using elenment-wise logical operators!  For example:
%   - both = rdtFilterStructArray(...) & rdtFilterStructArray(...)
%   - either = rdtFilterStructArray(...) | rdtFilterStructArray(...)
%
% structArray = rdtFilterStructArray(structArray, fieldName, fieldValue, varargin)
%
% Copyright (c) 2016 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('structArray', @isstruct);
parser.addRequired('fieldName', @ischar);
parser.addRequired('fieldValue');
parser.addParameter('matchStyle', 'exact', @(ms) strcmp('exact', ms) || strcmp('prefix', ms) || isa(ms, 'function_handle'));
parser.parse(structArray, fieldName, fieldValue, varargin{:});
structArray = parser.Results.structArray;
fieldName = parser.Results.fieldName;
fieldValue = parser.Results.fieldValue;
matchStyle = parser.Results.matchStyle;

% resolve the matchStyle as a function
if strcmp('exact', matchStyle)
    isMatch = @isequal;
elseif strcmp('prefix', matchStyle)
    isMatch = @isPrefix;
elseif isa(matchStyle, 'function_handle')
    isMatch = matchStyle;
else
    error('rdtFilterStructArray:invalidMatchSyle', 'Invalid matchStyle');
end

% default "all elements match"
selector = true(size(structArray));
if isempty(fieldValue)
    return;
end

% check each element explicitly
for ii = 1:numel(structArray)
    selector(ii) = isMatch(fieldValue, structArray(ii).(fieldName));
end
structArray = structArray(selector);

%% Does string b start with string a?
function prefix = isPrefix(a, b)
prefix = false;
if ~ischar(a) || ~ischar(b)
    return;
end
index = strfind(b,a);
prefix = ~isempty(index) && 1 == index;
