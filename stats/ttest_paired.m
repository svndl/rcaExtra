function [pValue, h0] = ttest_paired(varargin) 
    nargs = size(varargin, 2);
    switch nargs
        case 1
            cellArray1 = varargin{1};
            cellArray2 = {};
            RC = 1;
        case 2
            cellArray1 = varargin{1};            
            if (iscell(varargin{2}))
                cellArray2 = varargin{2};
                RC = 1;
            else
                cellArray2 = {};
                RC = varargin{2};
            end
        case 3
            cellArray1 = varargin{1};
            cellArray2 = varargin{2};
            RC = varargin{3};           
        otherwise
    end
    nIters = 7000;
    if (isempty(cellArray2))
        meanVals = cellfun(@(x) squeeze(nanmean(squeeze(x(:, RC, :)), 2)), cellArray1, 'uni', false);
        meanVals1 = meanVals(:, 1);
        meanVals2 = meanVals(:, 2);
        var1 = cat(2, meanVals1{:});
        var2 = cat(2, meanVals2{:});
        % shuffle order
        var11 = var1 - repmat(var1(1, :), [size(var1, 1) 1]);
        var22 = var2 - repmat(var2(1, :), [size(var2, 1) 1]);
        
        [~, pValue, h0, ~, ~] = ttest_permute_paired(var11, var22, nIters);                
    else
    
        meanVals1 = cellfun(@(x) squeeze(nanmean(squeeze(x(:, RC, :)), 2)), cellArray1, 'uni', false);
        meanVals2 = cellfun(@(x) squeeze(nanmean(squeeze(x(:, RC, :)), 2)), cellArray2, 'uni', false);
        var1 = cat(2, meanVals1{:});
        var2 = cat(2, meanVals2{:});
        var11 = var1 - repmat(var1(1, :), [size(var1, 1) 1]);
        var22 = var2 - repmat(var2(1, :), [size(var2, 1) 1]);
        [~, pValue, h0, ~, ~] = ttest_permute(var1 - var2, nIters);        
    % shuffle the values
    end
    pValue(isnan(pValue)) = 1;
end