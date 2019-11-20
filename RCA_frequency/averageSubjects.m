function sAvg = averageSubjects(dataIn)
% Alexandra Yakovleva, Stanford University 2012-2020
% part of averageFrequencyData toolbox

    nCnd = size(dataIn, 1);
    nSubj = size(dataIn, 2);
    
    sAvg = cell(nCnd, nSubj);
    for c = 1:nCnd 
        sAvg(c, :) = cellfun(@(x) averageBinsPerTrials(x), ...
            squeeze(dataIn(c, :)), 'uni', false);
    end
end
