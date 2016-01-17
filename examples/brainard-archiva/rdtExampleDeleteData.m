%% This is a tutorial for the Remote Data Toolbox object-oriented API.
%
% This script shows how to delete data with the Remote Data Toolbox.
% Data artifacts can be deleted individually, or as groups.  Once deleted,
% artifacts are no longer available to read from the remote server or from
% the local artifact cache.
%
% This script uses a JSON file to configure a Remote Data Toolbox client
% object with things like the Url of the project's remote repository.  This
% simplifies various calls to the Remote Data Toolbox functions.
%
% You probably don't want to store your project's repository credentials in
% a JSON file, because others would be able to read it.  So before
% publishing data, this script will prompt you to enter a password into a
% dialog window.  For this demo, use the user name "test" and password
% "test123".
%
% See also rdtExampleReadData, rdtExamplePublishData
%
% Copyright (c) 2016 RemoteDataToolbox Team

clear;
clc;

%% Create a client object with project configuration and credentials.
client = RdtClient('brainard-archiva');
client.credentialsDialog();

%% Create 4 new artifacts and publish them.
% For this example, the artifacts are mat-files that contain string hobbit
% names.
pathName = 'hobbits';
hobbits = {'frodo', 'sam', 'merry', 'pippin'};

% create a temp folder to work in
tempFolder = fullfile(tempdir(), pathName);
if 7 ~= exist(tempFolder, 'dir')
    mkdir(tempFolder);
end

% save a temp mat file for each hobbit
nArtifacts = numel(hobbits);
tempFiles = cell(1, nArtifacts);
for ii = 1:nArtifacts
    name = hobbits{ii};
    tempFiles{ii} = fullfile(tempFolder, [name '.mat']);
    save(tempFiles{ii}, 'name');
end

% publish all the hobbits
client.crp(pathName);
published = client.publishArtifacts(tempFolder);

% these hobbits were published
fprintf('The following hobbits were published:\n');
for ii = 1:numel(published);
    fprintf('  %s\n', published(ii).artifactId);
end

%% Visit the hobbits on the web.
% You should see 4 names listed.
client.openBrowser();

%% Delete one or two hobbits.
% To delete specific artifacts, use elements of an artifact struct array,
% like the struct array returned from publishArtifacts().
victims = published([1,3]);

% Delete uses a plain-old-function.  BSH is not sure if this belongs in the
% RdtClient class because delete seems like a special case.
deleted = rdtDeleteArtifacts(client.configuration, victims);

% these ones were deleted!
fprintf('The following hobbits were deleted:\n');
for ii = 1:numel(deleted);
    fprintf('  %s\n', deleted(ii).artifactId);
end

%% Delete all the remaining hobbits.
% To delete many artifacts at once, use a remotePath that contains the
% artifacts.
victims = pathName;
deleted = rdtDeleteRemotePaths(client.configuration, victims);

% all of these were deleted!
fprintf('The following paths aka folders aka groups were deleted:\n');
for ii = 1:numel(deleted);
    fprintf('  %s\n', deleted{ii});
end

%% Check the web again.
% There should be no hobbits there!  You should see a 404 error or similar.
client.openBrowser();

%% Make sure we really can't read any of these hobbits.
% rdtDeleteArtifacts() and rdtDeleteRemotePaths() delete things remotely
% and also delete them from the local artifact cache.  This is important!
% If we didn't clean up locally, we would still be able to read the
% artifacts after they were deleted.  Let's verify that we can't read them.

% should fail to read artifacts
try
    [datas, artifacts] = client.readArtifacts(published);
    fprintf('For some reason we were able to read the deleted artifacts.\n');
    fprintf('This is not what we expected.\n');
catch ex
    fprintf('It looks like we could not read the deleted artifacts.\n');
    fprintf('That''s what we want!  The server said:\n%s\n', ex.message);
    datas = {};
    artifacts = {};
end
disp(datas)
disp(artifacts)
