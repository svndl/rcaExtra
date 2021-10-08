function [sig, pVal, stat] = computeStatsFreq(subjAvgReal, subjAvgImag)


    nFreqs  = size(subjAvgReal, 1);
    nCnd = size(subjAvgReal, 2);
    sig = zeros(nFreqs, 1);
    pVal = sig;
    stat = sig;
    
    if (nCnd > 2)
        disp('Need two conditions to test against each other, returning zero');
        return;
    end
    
    nSubj = size(subjAvgReal, 3);
    xyData = zeros(nSubj, 2, nCnd);
    
    %% STATS
    for f = 1:nFreqs
        for cnd = 1:nCnd
            tempReal = squeeze(subjAvgReal(f, cnd, :));
            tempImag = squeeze(subjAvgImag(f, cnd, :));
            xyData(:, :, cnd) = [tempReal, tempImag];
        end
        stats = tSquaredFourierCoefs(xyData);
        sig(f) = stats.H;
        pVal(f) = stats.pVal;
        stat(f) = stats.tSqrd;
    end
end
