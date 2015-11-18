%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Initialize a struct representation of a remote artifact.
%   @param varargin struct or name-value pairs of artifact metadata
%
% @details
% Returns a struct of metadata about a remote artifact, with required
% fields defined, such as @b remotePath, @b artifactId, and @b version.
% The given @a varargin may be a struct or a list of name-value pairs to
% fill in the required fields.
%
% @details
% Usage:
%   artifact = rdtArtifact(varargin)
%
% @ingroup utilities
function artifact = rdtArtifact(varargin)

parser = rdtInputParser();
parser.StructExpand = true;
parser.addParameter('url', '');
parser.addParameter('localPath', '');
parser.addParameter('repositoryId', '');
parser.addParameter('remotePath', '');
parser.addParameter('artifactId', '');
parser.addParameter('version', '');
parser.addParameter('type', '');

%% Parse the input through the input scheme.
parser.parse(varargin{:});
artifact = parser.Results;
