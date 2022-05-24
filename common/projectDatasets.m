function varargout = projectDatasets(W, varargin)
% function will project varargout data subsets using W
% W

% Input args:

% W weights for projection
% varargin: source data subset(s), cell arrays (nSubjs x nConditions),
% number of conditions can vary among datasets

% example use:

% [dataOut1, dataOut2] = rcaExtra_projectDataSubset(W, data1, data2)

% Alexandra Yakovleva, Stanford University 2020


    nDataSets = nargin - 1;
    varargout = cell(nDataSets, 1);
    % loop over input datasets
    for n = 1:nDataSets
         % compute averages for projected data
        varargout{n} = rcaExtra_projectCellData(varargin{n}, W);
    end
    
    %% in case we'll need re-writing/saving copy of data:
    
%     expression = '(^|\.)\s*.';
%     replace = '${upper($0)}';
%     newStr = regexprep(rcaResult.rcaSettings.domain, expression, replace);
%     
%     % rewriting, request new name from user
%    
%     str = input('Enter _NEW_ name for flipped weights, otherwise leave empty', 's');
%     
%     % if response is not empty, change label field and rename the structure
%     
%     if (~isempty(str))
%         updated_rcaResult.rcaSettings.label = str;
%     end
%     
%     % overwrite rcaResult
%     rcaResult = updated_rcaResult;
%     
%     % where to save the updated RC results struct
%     savedFile = fullfile(rcaResult.rcaSettings.destDataDir_RCA, ...
%         ['rcaResult_' newStr '_' rcaResult.rcaSettings.label '.mat']);
%     save(savedFile, 'rcaResult');
end