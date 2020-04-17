function avgBinPerTrialPerFeq = averageBinsPerTrials(dataIn)
% Alexandra Yakovleva, Stanford University 2012-1020
    
    % nBins x nF x nChannels x nTrials
    nChannels = size(dataIn, 3);
    nF = size(dataIn, 2);
    nTrials = size(dataIn, 4); 
    avgBinPerTrialPerFeq = squeeze(nanmean(dataIn, 1));
    %% add back single component dim (removed by squeeze); 
    avgBinPerTrialPerFeq = reshape(avgBinPerTrialPerFeq, [nF nChannels nTrials]);
end