function parser = rdtInputParser()
% Configure an inputParser with Remote Data Toolbox defaults
%
%    parser = rdtInputParser() 
%
% Return an instance of the built-in inputParser class, with its properties
% set to Remote Data Toolbox defaults.
%
% See also: inputParser
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = inputParser();

parser.CaseSensitive = true;
parser.KeepUnmatched = true;
parser.StructExpand = false;

% PartialMatching is not an option in Matlab < ~8.2/R2013b
% We turn it off when we have the choice.
if ~verLessThan('matlab', '8.2')
    parser.PartialMatching = false;
end

end