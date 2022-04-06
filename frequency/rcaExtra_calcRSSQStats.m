function [t, pValue] = rcaExtra_calcRSSQStats(factorMatrix1, factorMatrix2, nBins, nFreqs)

% Calculate RSSQ values for two factors, test factor significance

    [rssq1, w1] = calculatewRSSQ(factorMatrix1, nBins, nFreqs);
    [rssq2, w2] = calculatewRSSQ(factorMatrix2, nBins, nFreqs);

    [t, pValue] = rcaExtra_testRSSQFactors(rssq1, w1, rssq2, w2);
        
end