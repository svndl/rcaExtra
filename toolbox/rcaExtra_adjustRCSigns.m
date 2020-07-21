function [corrVars, flipIdx] = rcaExtra_adjustRCSigns(rcResult, sourceData)
% Function computes signs of RC components in a way that mimimizes the difference between
% source data and reconstructed RC signal

% Alexandra Yakovleva, Stanford University 2020

    % compute subject's average 
    rcDataAvg_cell = cellfun(@(x) nanmean(x, 3), rcResult.projectedData, 'uni', false);
    sensorDataAvg_cell = cellfun(@(x) nanmean(x, 3), sourceData, 'uni', false);
    
    % concatenate all subjects 
    rcDataAvg = cat(3, rcDataAvg_cell{:});
    sensorDataAvg = cat(3, sensorDataAvg_cell{:});
    % concatenate averaged data into 
    
    sensorSum = squeeze(sum(sensorDataAvg, 2));     
    nComp = rcResult.rcaSettings.nComp;
    
    outcomes_all = logical(dec2bin(0:2^nComp - 1) - '0');
    nComb_all = size(outcomes_all, 1);
    
    % cut in half due to symmetry  
    nComb = round(nComb_all);    
    outcomes = outcomes_all(1:nComb, :);

    tempCorr = zeros(nComb, 1);
    for c = 1:size(outcomes, 1)
        tempRCA = rcDataAvg;
        tempRCA(:, outcomes(c, :), :) = -1*rcDataAvg(:, outcomes(c, :), :);
        tempSum = squeeze(nansum(tempRCA, 2));
        tempCorr(c) = corr(mean(tempSum, 2), mean(sensorSum, 2));
        %tempCorr(c) = corr2(tempSum, sensorSum);
        
    end
    [corrVars, varIdx] = sort(abs(tempCorr), 'descend');
    flipIdx = outcomes(varIdx(1), :);
end
