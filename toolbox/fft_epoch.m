function dataOut = fft_epoch(dataIn)
% computes fft for each epoch

    [nSamples, nEpochs, nChannels] = size(dataIn);
    
    dataOut = NaN(nSamples, nEpochs, nChannels);
    
    for ie = 1:nEpochs
       epoch = squeeze(dataIn(:, ie, :));
       try
           dataOut(:, ie, :) = fft(epoch, [], 1);
       catch err
           fprintf('Epoch %d had NaN values \n', ie);
           % if has NaNs, fft will fail and epoch would be NaN
       end
    end
end