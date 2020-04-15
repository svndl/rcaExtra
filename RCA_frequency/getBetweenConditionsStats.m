function stats = getBetweenConditionsStats(inputData, nBs, nFs, W)
% Alexandra Yakovleva, Stanford University 2012-2020.

    [avgSubj_Re, avgSubj_Im] = averageSubjectFrequencyData(inputData, nBs, nFs, W); 
    nRcs = size(W, 2);
    sig = zeros(nFs, nRcs);
    pVal = zeros(nFs, nRcs);
    stat = zeros(nFs, nRcs);
    for rc = 1:nRcs
        avgSubj_re_cat = cat(3, avgSubj_Re{:});
        avgSubj_im_cat = cat(3, avgSubj_Im{:});
        [sig(:, rc), pVal(:, rc), stat(:, rc)] = computeStatsFreq(avgSubj_re_cat(:, rc, :), avgSubj_im_cat(:, rc, :)); 
    end
    stats.sig = sig;
    stats.pValues = pVal;
    stats.statistics = stat;
end
