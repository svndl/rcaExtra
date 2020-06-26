function listing = list_folder(folder, varargin)
%
% list folder content ignoring .,..,.DS, etc.
if (~isempty(varargin))
    listing = dir([folder filesep varargin{1}]);
else
    listing = dir(folder);
end
listing = listing(arrayfun(@(x) x.name(1), listing) ~= '.');