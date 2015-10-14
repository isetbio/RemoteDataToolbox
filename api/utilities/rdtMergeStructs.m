%%% RemoteDataToolbox Copyright (c) 2015 The RemoteDataToolbox Team.
%
%% Smash fields of the second struct onto the first struct.
%   @param target struct to receive fields from @a source
%   @param source struct to send fields to @a target
%   @param allowNewFields create new fields in the @a target struct?
%
% @details
% Assigns all field values from the @a source struct to the @a target
% struct.  This will replace matching fields of @a target.  By default,
% this may also create new fields in @a target.  If @a allowNewFields is
% false, will only replace but not create new fields in @a target.
%
% @details
% Usage:
%   target = rdtMergeStructs(target, source, allowNewFields)
%
% @ingroup utilities
function target = rdtMergeStructs(target, source, allowNewFields)

if nargin < 1 || ~isstruct(target)
    return;
end

if nargin < 2 || ~isstruct(source)
    return;
end

if nargin < 3 || isempty(allowNewFields)
    allowNewFields = true;
end

fields = fieldnames(source);
for ii = 1:numel(fields)
    field = fields{ii};
    
    if allowNewFields || isfield(target, field)
        target.(field) = source.(field);
    end
end
