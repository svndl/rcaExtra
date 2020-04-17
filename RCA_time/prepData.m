function [muData, semData] = prepData(rcaDataIn)

    rcaDataMean = cellfun(@(x) nanmean(x, 3), rcaDataIn, 'uni', false);
    catData = cat(3, rcaDataMean{:});
    muData = nanmean(catData, 3);
    muData = muData - repmat(muData(1, :), [size(muData, 1) 1]);
    semData = nanstd(catData, [], 3)/(sqrt(size(catData, 3)));
end