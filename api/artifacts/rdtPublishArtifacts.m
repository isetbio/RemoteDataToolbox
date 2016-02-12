function artifacts = rdtPublishArtifacts(configuration, folder, remotePath, varargin)
%% Publish multiple artifacts to a remote repository path.
%
% artifacts = rdtPublishArtifacts(configuration, folder, remotePath)
% publishes each of the files in folder as an artifact to the repository at
% the remotePath. Sub-directories are not included. And special files
% (e.g., '.' or '..') are not included.
%
% configuration.repositoryUrl must point to the repository root.
%
% The artifactId of each artifact will be the same as the file base name.
% The type of each artifact will be the same as the file extension.
%
% artifact = rdtPublishArtifacts(... 'version', version) uses the
% given version for all published artifacts instead of the default '1'.
%
% artifact = rdtPublishArtifacts( ... 'description', description) adds
% the given description to the metadata for each artifact.  The default is
% no description.
%
% artifact = rdtPublishArtifacts( ... 'name', name) adds the given
% name to the metadata for each artifact.  The default is no name.
%
% artifact = rdtPublishArtifacts(... 'type', type) restricts publication to
% only files that have the same file extension as the given type.
%
% artifact = rdtPublishArtifacts( ... 'deleteLocal', deleteLocal) choose
% whether to delete the artifacts from the local cache after publishing.
% The default is false, leave the artifacts in the local cache.
%
% artifact = rdtPublishArtifacts( ... 'rescan', rescan) choose
% whether to request the remote repository to update its artifact listing
% and search index.  The default is true -- rescan and update.
%
% Returns a struct array of metadata about the published artifacts, or []
% if the publication failed.
%
% See also: rdtArtifact rdtPublishArtifact
%
% artifacts = rdtPublishArtifacts(configuration, folder, remotePath, varargin)
%
% *N.B.* In some cases, the file has may have two meaningful extensions,
% say FILE.nii.gz for neuroimaging data (NIfTI format).  In that case the
% extension '.gz' treated as the type.
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('configuration');
parser.addRequired('folder', @ischar);
parser.addRequired('remotePath', @(p)ischar(p) && ~isempty(p));
parser.addParameter('version', '1', @ischar);
parser.addParameter('type', '', @ischar);
parser.addParameter('description', '', @ischar);
parser.addParameter('name', '', @ischar);
parser.addParameter('deleteLocal', false, @islogical);
parser.addParameter('rescan', true, @islogical);
parser.parse(configuration, folder, remotePath, varargin{:});
configuration = rdtConfiguration(parser.Results.configuration);
type = parser.Results.type;
name = parser.Results.name;
folder     = parser.Results.folder;
remotePath = parser.Results.remotePath;
version    = parser.Results.version;
description = parser.Results.description;
deleteLocal = parser.Results.deleteLocal;
rescan      = parser.Results.rescan;

artifacts = [];

%% Choose artifacts to publish.
%
% '.' and '..' directory files are excluded.
% '.DS_Store' file is excluded (Apple directory store files)
% '.ASV' files are excluded (these are Matlab editor backup files)
%
folderListing = dir(folder);
nFiles = numel(folderListing);
isChosen = false(1, nFiles);
for ii = 1:nFiles
    listing = folderListing(ii);
    
    if listing.isdir
        continue;
    end
    
    [~, fileBase, fileExt] = fileparts(listing.name);
    fileType = fileExt(fileExt ~= '.');
    
    % Checking for DS_Store must be first
    isChosen(ii) = ...
        ~strcmpi('.DS_Store',fileExt) ...
        && '.' ~= fileBase(1) ...
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
    [~, artifactId] = fileparts(file);
    artifactCell{ii} = rdtPublishArtifact(configuration, ...
        file, ...
        remotePath, ...
        'artifactId', artifactId, ...
        'version', version, ...
        'description', description, ...
        'name', name, ...
        'deleteLocal', deleteLocal, ...
        'rescan', false);
end

artifacts = [artifactCell{:}];

%% Ask the remote server to rescan the repository?
if rescan
    rdtRequestRescan(configuration);
end

