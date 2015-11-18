function target = rdtMergeStructs(target, source, allowNewFields)
%% Smash fields of a source struct onto a target struct.
%
% target = rdtMergeStructs(target, source) assigns all field values from
% the source struct to the target struct.  This will update matching fields
% of target.  By default, this may also create new fields in the target
% struct.
%
% target = rdtMergeStructs(target, source, allowNewFields) obeys the
% optional flag allowNewFields.  If allowNewFields is false, no new fields
% will be added to the target struct.
%
% Returns the given target struct, which may have been updated with values
% from the source struct.
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('target', @isstruct);
parser.addRequired('source', @isstruct);
parser.addOptional('allowNewFields', true);
parser.parse(target, source, allowNewFields);
target = parser.Results.target;
source = parser.Results.source;
allowNewFields = parser.Results.allowNewFields;

fields = fieldnames(source);
for ii = 1:numel(fields)
    field = fields{ii};
    
    if allowNewFields || isfield(target, field)
        target.(field) = source.(field);
    end
end
