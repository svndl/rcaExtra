function [sig, pVal, stat] = getBetweenPopulationStats(inputData1, nBins1, inputData2, nBins2, nF, W)
% Alexandra Yakovleva, Stanford University 2012-2020.


    [avgSubj_Re_1, avgSubj_Im_1] = averageSubjectFrequencyData(inputData1, nBins1, nF, W);   
    [avgSubj_Re_2, avgSubj_Im_2] = averageSubjectFrequencyData(inputData2, nBins2, nF, W);   

    [sig, pVal, stat] = computeStatsFreqBetween(avgSubj_Re_1, avgSubj_Im_1, avgSubj_Re_2, avgSubj_Im_2);  
end
