function artifact = rdtArtifact(varargin)
%% Initialize a struct of metadata abouta remote artifact.
%
% This function initializes a struct with metadata describing a remote
% artifact.  Metadata fields begin with default values declared in 
% this function.  These may be amended with values passed in as a struct or
% name-value pairs.
%
% artifact = rdtArtifact(initialArtifact) amends the default
% metadata using fields from the given initialArtifact struct.
%
% artifact = rdtArtifact('field1', value1, 'field2', value2, ...)
% amends the default metadata using the named field-value pairs.
%
% Returns a struct with artifat metadata with at least the default
% values and only the expected fields defined.
%
% artifact = rdtArtifact(varargin)
%
% Copyright (c) 2015 RemoteDataToolbox Team

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
