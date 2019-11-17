function out = reBinSession(sessionData, nFreq, nBins_new)

    %half of bins
    [nBinSamples, ~, ~] = size(sessionData);
    
    real_part = sessionData(1:nBinSamples/2, :, :);
    imag_part = sessionData(1 + nBinSamples/2:end, :, :);
    
    [nBinsFreqs, nCh, nTrials] = size(real_part);
    nBins_curr = nBinsFreqs/nFreq;
    
    
    real_part_byBin = reshape(real_part, [nBins_curr nFreq nCh nTrials]);
    imag_part_byBin = reshape(imag_part, [nBins_curr nFreq nCh nTrials]);
    
    real_part_byBin_new = real_part_byBin(1:nBins_new, :, :, :);
    imag_part_byBin_new = imag_part_byBin(1:nBins_new, :, :, :);
    
    real_part_new = reshape(real_part_byBin_new, [nBins_new*nFreq, nCh nTrials]);
    imag_part_new = reshape(imag_part_byBin_new, [nBins_new*nFreq, nCh nTrials]);
    
    out = cat(1, real_part_new, imag_part_new);
end
