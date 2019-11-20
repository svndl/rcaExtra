function [muData, semData] = prepData(rcaDataIn)
% Alexandra Yakovleva, Stanford University 2012-2020

% average and compute mean/std values for a dataset

    rcaDataMean = cellfun(@(x) nanmean(x, 3), rcaDataIn, 'uni', false);
    catData = cat(3, rcaDataMean{:});
    muData = nanmean(catData, 3);
    muData = muData - repmat(muData(1, :), [size(muData, 1) 1]);
    semData = nanstd(catData, [], 3)/(sqrt(size(catData, 3)));
end
