function [sig, pVal, stat] = getBetweenConditionsStats(inputData, nBs, nFs, W)
% Alexandra Yakovleva, Stanford University 2012-2020.

    [avgSubj_Re, avgSubj_Im] = averageSubjectFrequencyData(inputData, nBs, nFs, W);   
    [sig, pVal, stat] = computeStatsFreq(cat(3, avgSubj_Re{:}), cat(3, avgSubj_Im{:})); 
end
