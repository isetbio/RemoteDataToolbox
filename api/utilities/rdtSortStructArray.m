function [sorted, order] = rdtSortStructArray(structArray, fieldName)
%% Sort a struct array based on the values in one field.
%
% sorted = rdtSortStructArray(structArray, fieldName) sorts elements
% elements of the given structArray, based on the values of the field with
% the given fieldName.  Values of this field must be all numeric or all
% strings.  If the given structArray has no field with the given fieldName,
% returns the original structArray as-is.
%
% [sorted, order] = rdtSortStructArray(structArray ... ) also returns
% a set of ordered indices such that sorted = structArray(order).
%
% [sorted, order] = rdtSortStructArray(structArray, fieldName)
%
% Copyright (c) 2016 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('structArray', @(s) isempty(s) || isstruct(s));
parser.addRequired('fieldName', @ischar);
parser.parse(structArray, fieldName);
structArray = parser.Results.structArray;
fieldName = parser.Results.fieldName;

nElements = numel(structArray);
sorted = structArray;
order = 1:nElements;

%% Sanity check.
if isempty(structArray)
    return;
end

if ~isfield(structArray, fieldName)
    return;
end

%% Sort on the given field.
fieldValues = {structArray.(fieldName)};
if iscellstr(fieldValues)
    % sort string values
    [~, order] = sort(fieldValues);
else
    % treat all as numeric values
    %   replace missing values with nan to preserve element positions
    numericValues = nan(1, nElements);
    for ii = 1:nElements
        fieldValue = fieldValues{ii};
        if ~isempty(fieldValue) && isnumeric(fieldValue)
            numericValues(ii) = fieldValue;
        end
    end
    [~, order] = sort(numericValues);
end
sorted = structArray(order);
