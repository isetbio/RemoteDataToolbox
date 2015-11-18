%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Convert the given struct or array to a JSON string.
%   @param data struct or array to convert to JSON
%
% @details
% Returns a reasonable JSON string representation of the given @a data.
% See also rdtFromJson().
%
% @details
% Usage:
%   jsonString = rdtToJson(data)
%
% @ingroup utilities
function jsonString = rdtToJson(data)

parser = rdtInputParser();
parser.addRequired('data', @(data) isstruct(data) || iscell(data) || isnumeric(data));
parser.parse(data);
data = parser.Results.data;

jsonString = savejson('', data, ...
    'FloatFormat', '%.16g', ...
    'ArrayToStruct', 0, ...
    'ParseLogical', 1);
