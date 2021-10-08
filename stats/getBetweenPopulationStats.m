function stats = getBetweenPopulationStats(inputData1, nBins1, inputData2, nBins2, nF, W)
% Alexandra Yakovleva, Stanford University 2012-2020.

    [avgSubj_Re_1, avgSubj_Im_1] = averageSubjectFrequencyData(inputData1, nBins1, nF, W);   
    [avgSubj_Re_2, avgSubj_Im_2] = averageSubjectFrequencyData(inputData2, nBins2, nF, W);   

    nRc = size(W, 2);
    sig = zeros(nF, nRc);
    pVal = zeros(nF, nRc);
    stat = zeros(nF, nRc);
    avgSubj1_re_cat = cat(3, avgSubj_Re_1{:});
    avgSubj1_im_cat = cat(3, avgSubj_Im_1{:});
    avgSubj2_re_cat = cat(3, avgSubj_Re_2{:});
    avgSubj2_im_cat = cat(3, avgSubj_Im_2{:});
    
    for rc = 1:nRc
        s1.subjAvgReal = avgSubj1_re_cat(:, rc, :);
        s1.subjAvgImag = avgSubj1_im_cat(:, rc, :);
        s2.subjAvgReal = avgSubj2_re_cat(:, rc, :);
        s2.subjAvgImag = avgSubj2_im_cat(:, rc, :);
        
        [sig(:, rc), pVal(:, rc), stat(:, rc)] = rcaExtra_tSquared(s1, s2); 
    end
    stats.sig = sig;
    stats.pValues = pVal;
    stats.statistics = stat; 
end
