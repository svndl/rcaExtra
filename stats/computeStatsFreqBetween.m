function [sig, pVal, stat] = computeStatsFreqBetween(subjAvgReal1, subjAvgImag1, subjAvgReal2, subjAvgImag2)
% Alexandra Yakovleva, Stanford University 2012-2020.

    nFreqs  = size(subjAvgReal1, 1);  
    nCnd = size(subjAvgReal1, 2);
    
    sig = zeros(nFreqs, 1);
    pVal = sig;
    stat = sig;
    
    if (nCnd > 2)
        disp('Need two conditions to test against each other, returning zero');
        return;
    end
    
    nSubj1 = size(subjAvgReal1, 3);
    nSubj2 = size(subjAvgReal2, 3);
    
    xyData1 = zeros(nSubj1, 2, nCnd);
    xyData2 = zeros(nSubj2, 2, nCnd);
    
    %% STATS
    for f = 1:nFreqs
        for cnd = 1:nCnd
            xyData1(:, :, cnd) = [squeeze(subjAvgReal1(f, cnd, :)), squeeze(subjAvgImag1(f, cnd, :))];
            xyData2(:, :, cnd) = [squeeze(subjAvgReal2(f, cnd, :)), squeeze(subjAvgImag2(f, cnd, :))];                
            stats = t2FC(xyData1, xyData2);
            sig(f, cnd) = stats.H;
            pVal(f, cnd) = stats.pVal;
            stat(f, cnd) = stats.tSqrd;
        end
    end
end