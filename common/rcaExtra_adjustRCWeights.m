function out = rcaExtra_adjustRCWeights(rcaResult, order)
% function will flip signs and adjust order of RC Weights and all related 
% projected data and topo maps

% Input args:

% rcaResult: RC result structure
% order: vector with position/sign:
% example, order = [1 2 3 .. nRCs] will keep current order/sign
% order = [-1 3 2 ...] would flip the sign of first RC and swap second and
% third weights

% Alexandra Yakovleva, Stanford University 2020

    %Check that order length matches number of components
    
    if (numel(order) ~= rcaResult.rcaSettings.nComp)
        fprintf('Number of elements in order vector % d doesn''t ...match the number of components %d :\n', ...
            numel(order), rcaResult.rcaSettings.nComp);
        return;
    end
    % regexp replacement 
    expression = '(^|\.)\s*.';
    replace = '${upper($0)}';
    newStr = regexprep(rcaResult.rcaSettings.domain, expression, replace);
    
    
    % copy existing results
    updated_rcaResult = rcaResult;
    
    % lambda function
    reorder_flip = @(x, y) x(:, abs(y)).*sign(y);
    
    % update weights first
    updated_rcaResult.W = reorder_flip(rcaResult.W, order);
    
    % update topos
    updated_rcaResult.A = reorder_flip(rcaResult.A, order);
    
    % update projected data
    updated_rcaResult.projectedData = cellfun(@(x) x(:, abs(order), :).*sign(order), ...
        rcaResult.projectedData, 'uni', false);
    
    % if frequency domain, update noise bands as well
    if strcmp(newStr, 'Freq')
        try
            updated_rcaResult.noiseData.lowerSideBand = cellfun(@(x) x(:, abs(order), :).*sign(order), ...
            rcaResult.noiseData.lowerSideBand, 'uni', false);
            updated_rcaResult.noiseData.higherSideBand = cellfun(@(x) x(:, abs(order), :).*sign(order), ...
            rcaResult.noiseData.higherSideBand, 'uni', false);
        catch err
        end
    end
    
    % display old topo data top row, new topo data second row
    f = rcaExtra_compareTopoMaps(rcaResult.A, updated_rcaResult.A);
    f.Name = rcaResult.rcaSettings.label;

    % populate updated_rcaResult with computed averages
    out = rcaExtra_computeAverages(updated_rcaResult);    
    
    % save or return new result?
    str = input('Save as a new result structure? Y for yes, N for no', 's');
    
    % if save, prompt for a different name 
    
    if(strcmp(str, 'Y'))  
        % rewriting, request new name from user
        str = input('Enter _NEW_ name for updated results, otherwise leave empty (old file will be overwritten):', 's');
        
        % if response is not empty, change label field and rename the structure
        
        if (~isempty(str))
            updated_rcaResult.rcaSettings.label = str;
        end
        
        % overwrite rcaResult
        rcaResult = updated_rcaResult;
        
        % where to save the updated RC results struct
        savedFile = fullfile(rcaResult.rcaSettings.destDataDir_RCA, ...
            ['rcaResults_' newStr '_' rcaResult.rcaSettings.label '.mat']);
        save(savedFile, 'rcaResult');
    end
end