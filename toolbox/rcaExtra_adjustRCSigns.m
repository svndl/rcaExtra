function output = rcaExtra_adjustRCSigns(rcResult, sourceData)
% Function computes signs of RC components in a way that mimimizes the difference between
% source data and reconstructed RC signal

% Alexandra Yakovleva, Stanford University 2020

    % extract correct conditions
    if (~isempty(rcResult.rcaSettings.useCnds))
        dataSlice = sourceData(:, rcResult.rcaSettings.useCnds);
    else
        dataSlice = sourceData;
    end
    
    % project data
    projectedData = rcaProject(dataSlice, rcResult.W);
    
    % compute subject's average 
    rcDataAvg_cell = cellfun(@(x) nanmean(x, 3), projectedData, 'uni', false);
    sensorDataAvg_cell = cellfun(@(x) nanmean(x, 3), dataSlice, 'uni', false);
    
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

    tempCorr_2d = zeros(nComb, 1);
    tempCorr_avg = zeros(nComb, 1);
    for c = 1:size(outcomes, 1)
        tempRCA = rcDataAvg;
        %flip the signs of columns (if outcomes == 1)   
        tempRCA(:, outcomes(c, :), :) = -1*rcDataAvg(:, outcomes(c, :), :);
        % sum RC components
        tempSum = squeeze(nansum(tempRCA, 2));
        % compute 2d and 1d correlations
        tempCorr_avg(c) = corr(mean(tempSum, 2), mean(sensorSum, 2));
        tempCorr_2d(c) = corr2(tempSum, sensorSum);
        
    end
    % sort by correlation values, high to low
    [corrVars_2d, varIdx_2d] = sort((tempCorr_2d), 'descend');   
    [corrVars_avg, varIdx_avg] = sort((tempCorr_avg), 'descend');
    
    output.corrVars_2d = corrVars_2d;
    output.corrVars_avg = corrVars_avg;
    
    output.flipIdx_avg = outcomes(varIdx_avg(1), :);
    output.flipIdx_2d = outcomes(varIdx_2d(1), :);
end
