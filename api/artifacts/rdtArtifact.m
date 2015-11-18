%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Initialize a struct representation of a remote artifact.
%   @param varargin struct or name-value pairs of artifact metadata
%
% @details
% Returns a struct of metadata about a remote artifact, with required
% fields defined, such as @b remotePath, @b artifactId, and @b version.
% The given @a varargin may be a struct or a list of name-value pairs to
% replace fill in the required fields.
%
% @details
% Usage:
%   artifact = rdtArtifact(varargin)
%
% @ingroup utilities
function artifact = rdtArtifact(varargin)

%% What did the user pass in?
artifactArgs = struct();
if 1 == nargin
    % passed in name-value paris
    argin = varargin{1};
    if isstruct(argin)
        artifactArgs = argin;
    end
elseif 1 < nargin && 0 == mod(nargin, 2)
    % passed in name-value paris
    artifactArgs = struct(varargin{:});
end

%% Source of truth for artifact metadata expected fields.
artifact = struct( ...
    'url', '', ...
    'localPath', '', ...
    'repositoryId', '', ...
    'remotePath', '', ...
    'artifactId', '', ...
    'version', '', ...
    'type', '');

artifact = rdtMergeStructs(artifact, artifactArgs, false);
