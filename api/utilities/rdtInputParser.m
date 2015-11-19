function parser = rdtInputParser()
%% Get an inputParser configured with Remote Data Toolbox conventions.
%
% parser = rdtInputParser() returns an instance of the built-in inputParser
% class, with its properties set to Remote Data Toolbox defaults.
%
% See also inputParser
%
% parser = rdtInputParser()
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = inputParser();

parser.CaseSensitive = true;
parser.KeepUnmatched = true;
parser.PartialMatching = false;
parser.StructExpand = false;
