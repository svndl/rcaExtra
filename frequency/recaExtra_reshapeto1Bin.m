function rcaResult_1Bin = recaExtra_reshapeto1Bin(rcaResult)

% based on Blair's reshaping code
% modified to operate on arbitraty number of bins and same number of
% harmonics

% reshapes contents of rcaResult structure

    % number of frequencies used for analysis
    
    nFreqs = numel(rcaResult.rcaSettings.useFrequencies);

    % reshape projectAvg ans noise
    new_ProjectedData = cellfun(@(x) rcaExtra_reshapeBinsToTrials(x, nFreqs), ...
        rcaResult.projectedData, 'Uni', false);
    new_noiseHI = cellfun(@(x) rcaExtra_reshapeBinsToTrials(x, nFreqs),...
        rcaResult.noiseData.higherSideBand, 'Uni', false);  
    new_noiseLO = cellfun(@(x) rcaExtra_reshapeBinsToTrials(x, nFreqs),...
        rcaResult.noiseData.lowerSideBand, 'Uni', false);
    
    % copy structure and re-compute averages;
    rcaResult_new = rcaResult;
    rcaResult_new.rcaSettings.useBins = 1;
    rcaResult_new.projectedData = new_ProjectedData;
    rcaResult_new.noiseData.higherSideBand = new_noiseHI;
    rcaResult_new.noiseData.lowerSideBand = new_noiseLO;
    
    rcaResult_1Bin = rcaExtra_computeAverages(rcaResult_new);  
end

