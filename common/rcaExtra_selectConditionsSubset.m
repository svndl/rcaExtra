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
        rcaSubsetOut = [];
        return;
    end
    
    
    % copy input to output
    rcaSubsetOut = rcaResult;
    
    % adjust number of conditions
    rcaSubsetOut.rcaSettings.useCnds = numel(conditionVector);
    
    % select subset of conditions from projectedData
    rcaSubsetOut.projectedData = rcaResult.projectedData(:, conditionVector);
end