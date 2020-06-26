function [nfData, filteredData] = rcaExtra_filterEpochs(rawData, frequenciesHz)
%% INPUT ARGS
%   rawData: input raw signal can be cell matrix of subjects x conditions
%   rawData{x, y} is subject X condition Y with dimentions nTimesamples x nChannels x nTrials
%   if rawData is a single subject, it'll be converted to cell
%   
%   frequenciesHz: vector of frequencies to filter out    
%
%% OUTPUT ARGS
%   nFSignal has filtered data
%   remainingSignal has the rest of the data

%% convert frequencies to indicies first:
    % convert frequencies to sampling intervals
    DAQ_Rate = 420; % 420 NS-400 amplifier sampling rate per second
    
    filterSettings.nfIdx = round(DAQ_Rate./frequenciesHz);
    
    if (~iscell(rawData))
        rawData = {rawData};
    end
    % average across trials
    meanData = cellfun(@(x) nanmean(x, 3), rawData, 'uni', false);
    % fast fouirier
    fftData = cellfun(@(x) fft(x), meanData, 'uni', false);
    % do the split
    [d1, d2] = cellfun(@(x) splitData(x, filterSettings.nfIdx), fftData, 'uni', false);
    % split the data
    
    % reverse FFT
    d1_re = cellfun(@(x) ifft(x), d1, 'uni', false);
    d2_re = cellfun(@(x) ifft(x), d2, 'uni', false);
    
    % extract real part
    nfData_avg = cellfun(@(x) real(x), d1_re, 'uni', false);
    filteredData_avg = cellfun(@(x) real(x), d2_re, 'uni', false);
    
    % subtract averaged data from original raw data 
    filterOut = @(x, y) x - repmat(y, [1 1 size(x, 3)]);
    
    % taking average filtered signals out trial by trial 
    nfData = cellfun(@(x, y) filterOut(x, y), rawData, filteredData_avg, 'uni', false);
    filteredData = cellfun(@(x, y) filterOut(x, y), rawData, nfData_avg, 'uni', false);
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
