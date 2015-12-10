function withSlashes = rdtPathDotsToSlashes(withDots)
%% Convert a path from dot style to slash style.
%
% withSlashes = rdtPathDotsToSlashes(withDots) converts the given path
% withDots to an equivalent path with slashes.  For example "foo.bar"
% converts to "/foo/bar".
%
% See also rdtPathSlashesToDots
%
% withDots = rdtPathSlashesToDots(withSlashes)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('withDots', @ischar);
parser.parse(withDots);
withDots = parser.Results.withDots;

pathParts = rdtPathParts(withDots, 'separator', '.');
withSlashes = rdtFullPath(pathParts, 'separator', '/');
