function withDots = rdtPathSlashesToDots(withSlashes)
%% Convert a path from slash style to dot style.
%
% withDots = rdtPathSlashesToDots(withSlashes) converts the given path
% withSlashes to an equivalent path with dots.  For example "/foo/bar/"
% converts to "foo.bar".
%
% See also rdtPathDotsToSlashes
%
% withDots = rdtPathSlashesToDots(withSlashes)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('withSlashes', @ischar);
parser.parse(withSlashes);
withSlashes = parser.Results.withSlashes;

pathParts = rdtPathParts(withSlashes, 'separator', '/');
withDots = rdtFullPath(pathParts, ...
    'separator', '.', ...
    'trimLeading', true, ...
    'trimTrailing', true);
