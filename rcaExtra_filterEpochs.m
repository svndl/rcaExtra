function [nfData, filteredData] = rcaExtra_filterEpochs(rawData, filterSettings)
%% INPUT ARGS
%   rawData :input raw signal (cell data)
%   filterSettings.nfIdx multiples of nF1    
%
%% OUTPUT ARGS
%   nFSignal has nf1 data
%   remainingSignal has the rest of the data 

    meanData = cellfun(@(x) nanmean(x, 3), rawData, 'uni', false);
    fftData = cellfun(@(x) fft(x), meanData, 'uni', false);
    [d1, d2]= cellfun(@(x) splitData(x, filterSettings.nfIdx), fftData, 'uni', false);
    % split the data
    
    % do reverse FFTN
    d1_re = cellfun(@(x) ifft(x), d1, 'uni', false);
    d2_re = cellfun(@(x) ifft(x), d2, 'uni', false);
    
    % extract real part          
    nfData = cellfun(@(x) real(x), d1_re, 'uni', false);
    filteredData = cellfun(@(x) real(x), d2_re, 'uni', false);    
end
function [no_nFx, nFx] = splitData(array2D, idxVector)
    nIndicies = size(array2D, 1);
    limitVar = nIndicies*ones(size(idxVector));
    % generate indicies for multiple harmonics
    allIndicies =  arrayfun(@(x, y) x:x-1:y, idxVector, limitVar, 'uni', false);
    % merge data and remove duplicates
    idxF = unique(cat(2, allIndicies{:}));
    
    no_nFx = array2D;
    nFx = zeros(size(array2D));
    
    no_nFx(idxF, :) = 0;
    nFx(idxF, :) = array2D(idxF, :);
end
