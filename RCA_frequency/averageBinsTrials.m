function [weightedAvgPerBinPerFreq, ValidTrialsPerBinPerFreq] = averageBinsTrials(dataIn)
% Alexandra Yakovleva, Stanford University 2012-1020

    nFreq = size(dataIn, 2);
    nCh = size(dataIn, 3);

    ValidTrialsPerBinPerFreq = sum(~isnan(dataIn), 4);
    % nBins x nF x nChannels x nTrials
    meanBinsPerTrialPerFeq = nanmean(dataIn, 4);
    try
        weightedAvgPerBinPerFreq = squeeze(wmean(meanBinsPerTrialPerFeq, ValidTrialsPerBinPerFreq));
    catch
        weightedAvgPerBinPerFreq = zeros(nFreq, nCh); 
    end
    weightedAvgPerBinPerFreq = reshape(weightedAvgPerBinPerFreq, [nFreq nCh]);
end