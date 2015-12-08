function rdtPrintf(verbosity, format, varargin)
%% Print to the command window, depending of the verbosity level.
%
% rdtPrintf(verbosity, format, varargin) prints the given format string and
% additional arguments to the command window, just like fprintf().  It
% uses the given verbosity flag to decide whether to actually print, or to
% remain silent.
%
% This function is a convenience so that we can decide in one place how to
% interpret the verbosity flag, and so that other functions can still do
% printing as a one-liner.
%
% rdtPrintf(verbosity, format, varargin)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('verbosity', @isnumeric);
parser.addRequired('format', @ischar);
parser.parse(verbosity, format);
verbosity = parser.Results.verbosity;
format = parser.Results.format;

if verbosity >= 1
    fprintf(format, varargin{:});
end
