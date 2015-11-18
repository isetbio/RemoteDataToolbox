function jsonString = rdtToJson(data)
%% Convert a Matlab struct or array to a JSON string.
%
% jsonString = rdtToJson(data) takes the given Matlab data, which may be a
% struct, numeric array, or cell array, and converts it to a JSON string.
%
% See also rdtFromJson
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('data', @(data) isstruct(data) || iscell(data) || isnumeric(data));
parser.parse(data);
data = parser.Results.data;

jsonString = savejson('', data, ...
    'FloatFormat', '%.16g', ...
    'ArrayToStruct', 0, ...
    'ParseLogical', 1);
