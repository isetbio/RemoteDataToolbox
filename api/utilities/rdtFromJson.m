%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Convert the JSON string to an array or struct.
%   @param jsonString JSON string representation of an array or struct.
%
% @details
% Returns a Matlab array or struct which is a reasonable interpretation of
% the given @a jsonString.  See also rdtToJson().
%
% @details
% Usage:
%   data = rdtFromJson(jsonString)
%
% @ingroup utilities
function data = rdtFromJson(jsonString)

parser = rdtInputParser();
parser.addRequired('jsonString', @ischar);
parser.parse(jsonString);
jsonString = parser.Results.jsonString;

data = loadjson(jsonString);