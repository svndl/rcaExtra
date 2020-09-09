function [pValue, h0] = ttest_unpaired(dataIn1, dataIn2, flag)
    
    if (nargin < 3 || isempty(flag))
        flag = [];
        
    end
    RC = 1;
    nIters = 5000;
    
    meanVals1 = cellfun(@(x) squeeze(nanmean(squeeze(x(:, RC, :)), 2)), dataIn1, 'uni', false);
    meanVals2 = cellfun(@(x) squeeze(nanmean(squeeze(x(:, RC, :)), 2)), dataIn2, 'uni', false);
    var1 = cat(2, meanVals1{:});
    var2 = cat(2, meanVals2{:});
    var11 = var1 - repmat(var1(1, :), [size(var1, 1) 1]);
    var22 = var2 - repmat(var2(1, :), [size(var2, 1) 1]);
    
    [~, pValue, h0, ~, ~] = ttest_permute_unpaired(var11, var22, nIters, flag);
    pValue(isnan(pValue)) = 1;
end