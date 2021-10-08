function sAvg = averageSubjectsSweep(dataIn)
% Alexandra Yakovleva, Stanford University 2012-1020
% modified by LLV
%
    nCnd = size(dataIn, 2);
    nSubj = size(dataIn, 1);

    sAvg = cell(nSubj, nCnd);
    for c = 1:nCnd
        sAvg(:, c) = cellfun(@(x) averageBinsPerTrialsSweep(x), ...
            squeeze(dataIn(:, c)), 'uni', false);
    end
% sAvg = dataIn;
end