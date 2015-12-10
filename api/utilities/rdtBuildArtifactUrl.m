function url = rdtBuildArtifactUrl(repositoryUrl, remotePath, artifactId, version)
%% Build up a url to an artifact, from several parts.
%
% url = rdtBuildArtifactUrl(repositoryUrl, remotePath, artifactId, version)
% concatenates the given url parts into a full url, using the Maven
% repostory convention.  Takes care of some fussy things like removing
% extra url delimiters.
%
% url = rdtBuildArtifactUrl(repositoryUrl, remotePath, artifactId, version)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('repositoryUrl', @ischar);
parser.addRequired('remotePath', @ischar);
parser.addRequired('artifactId', @ischar);
parser.addRequired('version', @ischar);
parser.parse(repositoryUrl, remotePath, artifactId, version);
repositoryUrl = parser.Results.repositoryUrl;
remotePath = parser.Results.remotePath;
artifactId = parser.Results.artifactId;
version = parser.Results.version;

% don't include "+", which is a special case meaning "latest version"
if strcmp('+', version)
    version = '';
end

repoParts = rdtPathParts(repositoryUrl);
repoUrl = rdtFullPath(repoParts, ...
    'trimLeading', true, ...
    'trimTrailing', true);

remotePathParts = rdtPathParts(remotePath);
remotePath = rdtFullPath(remotePathParts, ...
    'trimLeading', true, ...
    'trimTrailing', true);

urlParts = {repoUrl, remotePath, artifactId, version};
url = rdtFullPath(urlParts, ...
    'trimLeading', true, ...
    'trimTrailing', true);

