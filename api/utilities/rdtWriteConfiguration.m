function configFile = rdtWriteConfiguration(configuration, projectName, varargin)
%% Write toolbox configuration to a file.
%
% configFile = rdtWriteConfiguration(configuration, projectName) writes the
% given toolbox configuration to a JSON file named for the given
% projectName.  For example, if projectName is "foo" writes a file named
% "rdt-config-foo.json".
%
% configFile = rdtWriteConfiguration(configuration, projectName, folder)
% writes the JSON file to the given folder instead of the default pwd().
%
% Returns the full path to the new JSON file.
%
% configFile = rdtWriteConfiguration(configuration, projectName, varargin)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('configuration');
parser.addRequired('projectName', @ischar);
parser.addOptional('folder', pwd(), @ischar);
parser.parse(configuration, projectName, varargin{:});
configuration = rdtConfiguration(parser.Results.configuration);
projectName = parser.Results.projectName;
folder = parser.Results.folder;

% destination file
jsonFileName = ['rdt-config-' projectName '.json'];
configFile = fullfile(folder, jsonFileName);

% convert to JSON
jsonString = rdtToJson(configuration);

% write it out
if 7 ~= exist(folder, 'dir')
    mkdir(folder);
end

fid = fopen(configFile, 'w');
fwrite(fid, jsonString);
fclose(fid);
