function [sig, pVal, stat] = rcaExtra_tSquaredWithin(dataSet1, dataSet2)
% Alexandra Yakovleva, Stanford University 2012-2020.

    nFreqs  = size(dataSet1.subjAvgReal, 1);  
    nCnd = size(dataSet1.subjAvgReal, 2);
    nSubj1 = size(dataSet1.subjAvgReal, 3);
    xyData1 = zeros(nSubj1, 2, nCnd);

     if (nCnd > 2)
        disp('Need two conditions to test against each other, returning zero');
        return;
    end
   
    sig = zeros(nFreqs, nCnd);
    pVal = sig;
    stat = sig;

    if (~isempty(dataSet2))   
        nSubj2 = size(dataSet2.subjAvgReal, 3);
        xyData2 = zeros(nSubj2, 2, nCnd);
    end
    
    %% STATS
    for f = 1:nFreqs
        for cnd = 1:nCnd
            % create real-imaginary pair for each condition/harmonic multiple
            
            xyData1(:, :, cnd) = [squeeze(dataSet1.subjAvgReal(f, cnd, :)), squeeze(dataSet1.subjAvgImag(f, cnd, :))];
            xyData2(:, :, cnd) = [squeeze(dataSet2.subjAvgReal(f, cnd, :)), squeeze(dataSet2.subjAvgImag(f, cnd, :))];                
            stats = tSquaredFourierCoefs(cat(3, xyData1, xyData2));                

            sig(f, cnd) = stats.H;
            pVal(f, cnd) = stats.pVal;
            stat(f, cnd) = stats.tSqrd;
        end
    end
end