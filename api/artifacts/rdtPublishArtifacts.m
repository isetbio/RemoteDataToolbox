%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
% Publish multiple artifacts to a remote repository path.
%   @param folder local path to a folder containing artifacts to publish
%   @param remotePath string remote path for all artifacts (defaults to folder name)
%   @param version string artifact version for all artifacts (defaults to '1')
%   @param type optional file exension to filter files in the @a folder
%   @param configuration optional RemoteDataToolbox configuration struct
%
% @details
% Publishes each of the files in the given @a folder as an artifact to a
% remote respository.  @a configuration.repositoryUrl should point to the
% repository root.
%
% @details
% Each published artifact will use the same @a remotePath and @a version.
% The artifactId of each artifact will be the same as the file base name.
% The type of each artifact will be the same as the file extension.
%
% @details
% By default, attempts to publish all of the files in the given @a folder.
% If @a type is provided, only publishes files that have that file
% extension.  Ignores files that start with '.', end with "~", or have
% extension ".ASV" or ".asv".
%
% @details
% Returns a struct array of metadata about the published artifacts,
% including their artifactIds, server urls, and local file paths within the
% artifact cache.  See rdtArtifact().
%
% @details
% If the publication fails, returns [].
%
% @details
% Usage:
%   artifacts = rdtPublishArtifacts(folder, remotePath, version, type, configuration)
%
% @ingroup artifacts
function artifacts = rdtPublishArtifacts(folder, remotePath, version, type, configuration)

artifacts = [];

if nargin < 3 || isempty(version)
    version = '1';
end

if nargin < 4 || isempty(type)
    type = '';
end

if nargin < 5 || isempty(configuration)
    configuration = rdtConfiguration();
else
    configuration = rdtConfiguration(configuration);
end

%% Choose artifacts to publish.
folderListing = dir(folder);
nFiles = numel(folderListing);
isChosen = false(1, nFiles);
for ii = 1:nFiles
    listing = folderListing(ii);
    
    if listing.isdir
        continue;
    end
    
    [filePath, fileBase, fileExt] = fileparts(listing.name);
    fileType = fileExt(fileExt ~= '.');
    
    isChosen(ii) = '.' ~= fileBase(1) ...
        && ~strcmpi('.ASV', fileExt) ...
        && '~' ~= fileExt(end) ...
        && (isempty(type) || strcmp(type, fileType));
end

%% Publish each artifact.
% TODO: optimize the multiple-artifact publish by including all artifacts
% in a single invocation of Gradle.  This should remove significant
% overhead from Gradle startup and network "chattiness".  We just have to
% figure out a good way to pass multiple artifacts to publish.gradle.

chosenListing = folderListing(isChosen);
nArtifacts = numel(chosenListing);
artifactCell = cell(1, nArtifacts);
for ii = 1:nArtifacts
    file = fullfile(folder, chosenListing(ii).name);
    [filePath, artifactId] = fileparts(file);
    artifactCell{ii} = rdtPublishArtifact(file, ...
        remotePath, ...
        artifactId, ...
        version, ...
        configuration);
end

artifacts = [artifactCell{:}];
