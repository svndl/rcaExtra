function dataOut3DMatrix = removeNaNTrials(dataIn3DMatrix)
% function will check 3D matrix for all NaN trials and removes
% them from data

    [~, ~, nTrials] = size(dataIn3DMatrix);
    useTrials = zeros(nTrials, 1);
    for nt = 1:nTrials
        
        if ~isempty(dataIn3DMatrix(~isnan(dataIn3DMatrix(:, :, nt))))
            useTrials(nt) = 1;
        end
    end
    
    dataOut3DMatrix = dataIn3DMatrix(:, :, boolean(useTrials));

end
