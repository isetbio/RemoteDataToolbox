%% t_rdRemoveArtifact
% 
% Illustrates uploading and then removing an artifact with the rdClient
%
% BW ISETBIO Team, 2017


%% login
rd = RdtClient('isetbio');
rd.credentialsDialog;

%% List the artifacts 
rd.crp('/resources/data/cmosaics')
rd.listArtifacts('print',true);

%% Create and publish the deleteme.jpg file
data = rand(32,32,3); imwrite(data,'deleteme.jpg'); thisFile = fullfile(pwd,'deleteme.jpg');
rd.publishArtifact(thisFile);
delete(thisFile);

% Show that deleteme is published
a = rd.listArtifacts('print',true);

%% Remove the deleteme artifact
% Find the artifactId named deleteme 
[~,idx] = ismember('deleteme',{a(:).artifactId});
rd.removeArtifacts(a(idx));

% Show the artifacts 
rd.listArtifacts('print',true);

%%
