function tagValue = rdtScrapeXml(xml, tagName, defaultValue)
%% Extract a Xml tag value.
%
% tagValue = rdtScrapeXml(xml, tagName, defaultValue) extracts the value
% under the given tagName from the given xml.  xml must be a string
% containing Xml text.
%
% If no value could be read from tagName, returns the given defaultValue
% instead.
%
% tagValue = rdtScrapeXml(xml, tagName, defaultValue)
%
% Copyright (c) 2015 RemoteDataToolbox Team

parser = rdtInputParser();
parser.addRequired('xml', @ischar);
parser.addRequired('tagName', @ischar);
parser.addRequired('defaultValue', @ischar);
parser.parse(xml, tagName, defaultValue);
xml = parser.Results.xml;
tagName = parser.Results.tagName;
defaultValue = parser.Results.defaultValue;

tagPattern = ['<' tagName '>([^<]*)</' tagName '>'];
tagMatches = regexp(xml, tagPattern, 'tokens');
if isempty(tagMatches)
    tagValue = defaultValue;
    return;
end
tagValue = tagMatches{1}{1};
