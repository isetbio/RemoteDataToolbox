function url = rdtBuildArtifactUrl(repositoryUrl, remotePath, artifactId, version, fileName)
%% Build up a url to an artifact, from several parts.
%
% url = rdtBuildArtifactUrl(repositoryUrl, remotePath, artifactId, version, fileName)
% concatenates the given url parts into a full url, using the Maven
% repostory convention.  Takes care of some fussy things like removing
% extra url delimiters.  If fileName is provided, the url will use the
% file name and extension at the end of the given fileName.
%
% url = rdtBuildArtifactUrl(repositoryUrl, remotePath, artifactId, version, fileName)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('repositoryUrl', @ischar);
parser.addRequired('remotePath', @ischar);
parser.addRequired('artifactId', @ischar);
parser.addRequired('version', @ischar);
parser.addRequired('fileName', @ischar);
parser.parse(repositoryUrl, remotePath, artifactId, version, fileName);
repositoryUrl = parser.Results.repositoryUrl;
remotePath = parser.Results.remotePath;
artifactId = parser.Results.artifactId;
version = parser.Results.version;
fileName = parser.Results.fileName;

% don't include "+", which is a special case meaning "latest version"
if strcmp('+', version)
    version = '';
end

repoParts = rdtPathParts(repositoryUrl);
repoUrl = rdtFullPath(repoParts, ...
    'trimLeading', true, ...
    'trimTrailing', true, ...
    'hasProtocol', true);

remotePathParts = rdtPathParts(remotePath);
remotePath = rdtFullPath(remotePathParts, ...
    'trimLeading', true, ...
    'trimTrailing', true);

% strip the file path, if any
[~, fileBase, fileExt] = fileparts(fileName);
fileNameNoPath = [fileBase fileExt];

urlParts = {repoUrl, remotePath, artifactId, version, fileNameNoPath};
url = rdtFullPath(urlParts, ...
    'trimLeading', true, ...
    'trimTrailing', true);

