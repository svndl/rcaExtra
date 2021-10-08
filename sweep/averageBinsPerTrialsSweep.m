function avgBinPerTrialPerFeq = averageBinsPerTrialsSweep(dataIn)
% Alexandra Yakovleva, Stanford University 2012-1020
    % LLV TODO: these bin-averaging aggregating functions are probably not
    % needed for the sweeps, for now it's just overridden, possibly get rid
    % of them
    % nBins x nF x nChannels x nTrials
    nBins = size(dataIn, 1);
    nChannels = size(dataIn, 3);
    nF = size(dataIn, 2);
    nTrials = size(dataIn, 4);
    avgBinPerTrialPerFeq = dataIn;
    return % this should not really apply to the sweep version, bins should be preserved instead of averaged over
    avgBinPerTrialPerFeq = squeeze(nanmean(dataIn, 1));
    %% add back single component dim (removed by squeeze); 
    avgBinPerTrialPerFeq = reshape(avgBinPerTrialPerFeq, [nBins nF nChannels nTrials]);
end