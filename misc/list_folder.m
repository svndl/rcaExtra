function listing = list_folder(folder, varargin)
% Alexandra Yakovleva, Stanford University 2012-2020

% list folder content ignoring .,..,.DS, etc.
if (~isempty(varargin))
    listing = dir([folder filesep varargin{1}]);
else
    listing = dir(folder);
end
listing = listing(arrayfun(@(x) x.name(1), listing) ~= '.');
