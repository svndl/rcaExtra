function varargout = rcaExtra_projectDataSubset(rcaResult, varargin)
% function will project varargout data subsets through weights from 
% rcaResult.W

% Input args:

% rcaResult: RC result structure with the weights you want to use for
% projection
% varargin: source data subset(s), cell arrays (nSubjs x nConditions),
% number of conditions can vary among datasets

% example use:

% [rcResult1, rcResult2] = rcaExtra_projectDataSubset(rcaResult, data1, data2)

% Alexandra Yakovleva, Stanford University 2020


    nDataSets = nargin - 1;
    W = rcaResult.W;
    varargout = cell(nargin, 1);
    % loop over input datasets
    for n = 1:nDataSets
    
        % make copy of rcaResult structure
        newData_rcaResult = rcaResult;
        
        % update number of conditions for each data subset
        newData_rcaResult.rcaSettings.useCnds = size(varargin{n}, 2);
        
        % project data through weights
        newData_rcaResult.projectedData = rcaProject(varargin{n}, W);
        
        % compute averages for projected data
        varargout{n} = rcaExtra_computeAverages(newData_rcaResult);
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