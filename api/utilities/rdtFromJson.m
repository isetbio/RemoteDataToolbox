function data = rdtFromJson(jsonString)
%% Convert a JSON string to a Matlab struct or array.
%
% data = rdtFromJson(jsonString) parses the given jsonString into Matlab
% data, which may be a struct, numeric array, or cell array.
%
% See also rdtToJson
%
% data = rdtFromJson(jsonString)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('jsonString', @ischar);
parser.parse(jsonString);
jsonString = parser.Results.jsonString;

if isempty(jsonString) || strcmp('[]', jsonString) || strcmp('{}', jsonString)
    data = [];
    return;
end

data = loadjson(jsonString);
