function [data_re, data_im] = getRealImag_byBin(inputData, nBins, nFreqs, nChs)
% Alexandra Yakovleva, Stanford University 2012-2020.
    [data_cos, data_sin] = getRealImag(inputData);
    data_re = cellfun(@(x) reshape(x, [nBins nFreqs nChs size(x, 3)]), data_cos, 'uni', false);
    data_im = cellfun(@(x) reshape(x, [nBins nFreqs nChs size(x, 3)]), data_sin, 'uni', false);
end