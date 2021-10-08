function [weightedAvgPerBinPerFreq, ValidTrialsPerBinPerFreq] = averageBinsTrialsSweep(dataIn)
% Alexandra Yakovleva, Stanford University 2012-1020
% modified by LLV
[nBins, nFreq, nCh, ~] = size(dataIn);

weightedAvgPerBinPerFreq = nan(nBins, nFreq, nCh);

ValidTrialsPerBinPerFreq = sum(~isnan(dataIn), 4);
% nBins x nF x nChannels x nTrials
meanBinsPerTrialPerFeq = nanmean(dataIn, 4);

try
    try
        % weighted average per bin per trial
        weightedAvgPerBinPerFreq = squeeze(wmean(meanBinsPerTrialPerFeq, ValidTrialsPerBinPerFreq, 4));
    catch
        weightedAvgPerBinPerFreq = zeros(nBins, nFreq, nCh);
    end
    weightedAvgPerBinPerFreq = reshape(weightedAvgPerBinPerFreq, [nBins, nFreq nCh]);
catch err
    rcaExtra_displayError(err);
end
% weightedAvgPerBinPerFreq = meanBinsPerTrialPerFeq
end