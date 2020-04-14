function pValue = ttest_between_pvalueOnly_time(dataIn1, dataIn2)
    RC = 1;
    meanVals1 = cellfun(@(x) squeeze(nanmean(squeeze(x(:, RC, :)), 2)), dataIn1, 'uni', false);
    meanVals2 = cellfun(@(x) squeeze(nanmean(squeeze(x(:, RC, :)), 2)), dataIn2, 'uni', false);
    
    nIters = 5000;
    [realT, pValue, corrT, critVal, ~] = ttest_permute_between(cat(2, meanVals1{:}), cat(2, meanVals2{:}), nIters);
    [realT1, pValue1, corrT1, critVal1, ~] = tTest_between(cat(2, meanVals1{:}), cat(2, meanVals2{:}), nIters);
end

