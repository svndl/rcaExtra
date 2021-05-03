function rcaSubsetOut = rcaExtra_selectConditionsSubset(rcaResult, conditionVector)
% function will extract a subset of conditions from rcaRerult

% Input arguments:
% rcaResult structure
% conditionVector -- vector of conditions or a single condition


% Output arg:
% new rcaSubsetOut structure with adjusted projectedData
% and rcaResult.rcaSettings.useCnds


    % check that requested subset is within the dataset range:
    nAvailableConditions = size(rcaResult.projectedData, 2);
    maxrequestedConditions = max(conditionVector);
    
    % if condition index is outside of range, display error and return
    % empty result
    if (nAvailableConditions < maxrequestedConditions)
        fprintf('ERROR, condition %d id out of availavle range %d\n', maxrequestedConditions, nAvailableConditions);
        rcaSubset = [];
        return;
    end
    
    
    % copy input to output
    rcaSubset = rcaResult;
    
    % adjust number of conditions
    rcaSubset.rcaSettings.useCnds = numel(conditionVector);
    
    % select subset of conditions from projectedData
    rcaSubset.projectedData = rcaResult.projectedData(:, conditionVector);
    
    % if frequency, select subset from noise
    try
        switch (rcaResult.rcaSettings.domain )
            case 'freq'
                rcaSubset.noiseData.lowerSideBand = rcaResult.noiseData.lowerSideBand(:, conditionVector);
                rcaSubset.noiseData.higherSideBand = rcaResult.noiseData.higherSideBand(:, conditionVector);  
            otherwise
        end
    catch err
        rcaExtra_displayError(err);
    end
    
    % recompute averages
    
    rcaSubsetOut = rcaExtra_computeAverages(rcaSubset);
end