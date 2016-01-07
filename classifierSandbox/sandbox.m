clear
clc

%% Harmless to show credentials to the demo repository.
client = RdtClient('brainard-archiva');
client.configuration.username = 'test';
client.configuration.password = 'test123';
client.crp('classifiers');

%% Publish 4 files as the "test" artifact, with different "classifiers".
sandboxFolder = fullfile(rdtRootPath(), 'classifierSandbox');
client.publishArtifact(fullfile(sandboxFolder, 'test.txt'));
client.publishArtifact(fullfile(sandboxFolder, 'test.foo'));
client.publishArtifact(fullfile(sandboxFolder, 'test.bar'));
client.publishArtifact(fullfile(sandboxFolder, 'test.quux'));

%% Now what do we see?
listed = client.listArtifacts('pageSize', 2);
artifactIds = {listed.artifactId}
types = {listed.type}

[datas, fetched] = client.readArtifacts(listed);
datas

%% POST version of quick search.
clc
resourcePath = '/restServices/archivaServices/searchService/quickSearchWithRepositories';
repo = client.configuration.repositoryName;

% quickSearchWithRepositories only uses 4 body fields
searchRequest = struct( ...
    'queryTerms', 'project', ...
    'repositories', {{repo, repo}}, ...
    'pageSize', 1000, ...
    'selectedPage', 0);
response = rdtRequestWeb(client.configuration, resourcePath, 'requestBody', searchRequest);
response{:}

%% POST for listing.
clc
resourcePath = '/restServices/archivaServices/searchService/searchArtifacts';
repo = client.configuration.repositoryName;

% searchArtifacts only uses these fields
searchRequest = struct( ...
    'groupId', 'classifiers', ...
    'artifactId', 'test', ...
    'version', '1', ....
    'packaging', 'txt', ...
    'classifier', 'txt', ...
    'pageSize', 1000);
response = rdtRequestWeb(client.configuration, resourcePath, 'requestBody', searchRequest);
response

%% GET free text from browse service.
clc

text = 'test';
resourcePath = ['/restServices/archivaServices/browseService/searchArtifacts/' text];

% searchArtifacts only uses these fields
queryParams = struct( ...
    'repositoryId', client.configuration.repositoryName, ...
    'exact', '1');
response = rdtRequestWeb(client.configuration, resourcePath, 'queryParams', queryParams);
response

%% GET group from browse service.
clc

groupId = 'classifiers';
resourcePath = ['/restServices/archivaServices/browseService/browseGroupId/' groupId];

% searchArtifacts only uses these fields
queryParams = struct( ...
    'repositoryId', client.configuration.repositoryName);
response = rdtRequestWeb(client.configuration, resourcePath, 'queryParams', queryParams);
response

%% GET all artifacts in a repo.
clc

repo = client.configuration.repositoryName;
resourcePath = ['/restServices/archivaServices/browseService/artifacts/' repo];

% searchArtifacts only uses these fields
response = rdtRequestWeb(client.configuration, resourcePath);
response

%% Trigger a scan!
configuration = rdtCredentialsDialog(rdtConfiguration('brainard-archiva'));
configuration.acceptMediaType = 'text/plain';
configuration.repositoryName = 'scien';
resourcePath = '/restServices/archivaServices/repositoriesService/scanRepositoryNow';
queryParams = struct( ...
    'repositoryId', configuration.repositoryName, ...
    'fullScan', 1);
response = rdtRequestWeb(configuration, resourcePath, 'queryParams', queryParams);

%% Delete one artifact!
configuration = client.configuration;
configuration.acceptMediaType = 'text/plain';
resourcePath = '/restServices/archivaServices/repositoriesService/deleteArtifact';
queryParams = struct( ...
    'repositoryId', client.configuration.repositoryName, ...
    'version', '1', ...
    'artifactId', 'test', ...
    'groupId', 'classifiers', ...
    'classifier', 'txt', ...
    'packaging', 'txt');
response = rdtRequestWeb(configuration, resourcePath, 'requestBody', queryParams);
response

cacheFolder = '~/.gradle';
gradleCache = fullfile(cacheFolder, 'caches', 'modules-2', 'files-2.1', ...
    queryParams.groupId, queryParams.artifactId, queryParams.version);
if 7 == exist(gradleCache, 'dir')
    if isempty(queryParams.classifier)
        % delete all local files for this artifact
        rmdir(gradleCache, 's');
    else
        % seek out one file inside the artifact
        dirContents = dir(gradleCache);
        nFolders = numel(dirContents);
        for ii = 1:nFolders
            dirEntry = dirContents(ii);
            if strcmp('.', dirEntry.name) || strcmp('..', dirEntry.name)
                continue;
            end
            
            subfolder = fullfile(gradleCache, dirEntry.name);
            fileName = [queryParams.artifactId '-' queryParams.version '-' queryParams.classifier '.' queryParams.packaging];
            target = fullfile(subfolder, fileName);
            if 2 == exist(target, 'file')
                rmdir(subfolder, 's');
            end
        end
    end
end

%% Delete a whole group!
configuration = client.configuration;
configuration.acceptMediaType = 'text/plain';
resourcePath = '/restServices/archivaServices/repositoriesService/deleteGroupId';
groupId = 'classifiers';
queryParams = struct( ...
    'repositoryId', client.configuration.repositoryName, ...
    'groupId', groupId);
response = rdtRequestWeb(configuration, resourcePath, 'queryParams', queryParams);

cacheFolder = '~/.gradle';
gradleCache = fullfile(cacheFolder, 'caches', 'modules-2', 'files-2.1', groupId);
if 7 == exist(gradleCache, 'dir')
    rmdir(gradleCache, 's');
end
