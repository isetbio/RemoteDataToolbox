%% t_rdtRemoveArtifact
% 
% Illustrates uploading and then removing an artifact with the RdtClient
%
% BW ISETBIO Team, 2017


%% Open and login

rdt = RdtClient('isetbio');
rdt.credentialsDialog;

%% List the artifacts 

rdt.crp('/resources/data/cmosaics')
rdt.listArtifacts('print',true);

%% Send up the deleteme.jpg file as an artifact

version1 = '1';
data = rand(32,32,3);
imwrite(data,'deleteme.jpg');
thisFile = fullfile(pwd,'deleteme.jpg');
rdt.publishArtifact(thisFile, 'version', version1);
delete(thisFile);

% List the artifacts to show what is there
a = rdt.listArtifacts('print',true);

%% Remove the artifact

% Find the artifactId named deleteme 
[~,idx] = ismember('deleteme',{a(:).artifactId});

% Remove the artifact with the deleteme id.
rdt.removeArtifacts(a(idx));

% The artifact should be deleted
rdt.listArtifacts('print',true);

%%
