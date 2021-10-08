function [proj, subj, w] = averageProjectSweep(dataIn, nBins)
% Alexandra Yakovleva, Stanford University 2012-1020
% LLV identical to frequency counterpart
    nCnd = size(dataIn, 2);
    proj = cell(nCnd, 1);
    subj = cell(size(dataIn));
    weights = cell(size(dataIn));
    % pool all subjects together
    if (nBins > 1)
        catDim = 4;
    else
        catDim = 4;
    end
    % cat together all subjects's trials 
    for c = 1:nCnd
        [proj{c}, ~] = averageBinsTrialsSweep(cat(catDim, dataIn{:, c}));
        [s, w] = cellfun(@(x) averageBinsTrialsSweep(x), dataIn(:, c), 'uni', false);
        subj(:, c) = s;
        weights(:, c) = w;
    end   
end