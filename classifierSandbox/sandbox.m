clear
clc

%% Harmless to show credentials to the demo repository.
client = RdtClient('brainard-archiva');
client.configuration.username = 'test';
client.configuration.password = 'test123';

%% Publish 4 files as the "test" artifact, with different "classifiers".
client.crp('classifiers');
sandboxFolder = fullfile(rdtRootPath(), 'classifierSandbox');
client.publishArtifact(fullfile(sandboxFolder, 'test.txt'));
client.publishArtifact(fullfile(sandboxFolder, 'test.foo'));
client.publishArtifact(fullfile(sandboxFolder, 'test.bar'));
client.publishArtifact(fullfile(sandboxFolder, 'test.quux'));

%% Now what do we see?
listed = client.listArtifacts();
artifactIds = {listed.artifactId}
types = {listed.type}

[datas, fetched] = client.readArtifacts(arti);
datas
