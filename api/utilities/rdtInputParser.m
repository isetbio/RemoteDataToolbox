%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Get an inputParser configured with Remote Data Toolbox conventions.
%
% @details
% Returns an instance of the built-in inputParser with properties set for
% Remote Data Toolbox
%
% @details
% Usage:
%   parser = rdtInputParser()
%
% @ingroup utilities
function parser = rdtInputParser()

parser = inputParser();

parser.CaseSensitive = true;
parser.KeepUnmatched = true;
parser.PartialMatching = false;
parser.StructExpand = false;
