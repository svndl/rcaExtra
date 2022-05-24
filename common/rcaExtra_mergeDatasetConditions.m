function dataOut = rcaExtra_mergeDatasetConditions(dataIn, cndRange)
% function will merge conditions and return a cell vector with same number
% of subjects(rows) and one condition

% Input arguments
% dataIN -- nSubj by nCnd 2D cell matrix, with each element
% dataIN{i, j} being 3D matrix of nSamples x nChannels x nTrials

% cndRange 1 d vector of condition indicies to merge. If empty, all conditions will
% be used

    [nSubjs, nCnds] = size(dataIn);

    if nargin < 2 || isempty(cndRange) 
        cndRange = 1:nCnds;
    end

    selectedData = dataIn(:, cndRange);
    dataOut = cell(nSubjs, 1);
    
    for ns = 1:nSubjs
        dataOut{ns} = cat(3, selectedData{ns, :});
    end
end