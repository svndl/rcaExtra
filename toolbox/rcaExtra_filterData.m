function dataOut = rcaExtra_filterData(rawData, freqsPresentHz, harmonicSelection, filterOperation)
%% INPUT ARGS
%   rawData: input raw signal can be cell matrix of subjects x conditions
%   rawData{x, y} is subject X condition Y with dimentions nTimesamples x nChannels x nTrials
%   if rawData is a single subject, it'll be converted to cell
%   
%   freqsPresentHz:  F1, F2 values in Hz
%   harmonicSelection: cell array string, options, 'nF1', 'nF2', 'nF1clean', 'nF2clean' 
%   filterOperation: string with two options: 'keep', 'remove'; 
%
%% OUTPUT ARGS
%   if filterOperation == 'keep' 
%   dataOut will be (!) epoch-average (!) harmonicSelection from rawData
%   if filterOperation == 'remove'
%   dataOut will be full trial with (!) harmonicSelection removed (!) from rawData

% Alexandra Yakovleva, Stanford University 2021

    DAQ_Rate = 420; % 420 NS-400 amplifier sampling rate per second

    if (~iscell(rawData))
        rawData = {rawData};
    end
    % pre-allocate/define the return values
    
%     cleanSignal = cell(size(rawData));
%     nFSignal = cell(size(rawData));
    
    cycleSizeSamplesPresent = round(DAQ_Rate./freqsPresentHz);
%    trialSizeSamples = size(rawData{1, 1}, 1);
    
    % shortest epoch to contain integer cycles of all frequencies
%     nEpochsMax = min(trialSizeSamples./cycleSizeSamplesPresent);
%     minEpochDurationSamples = trialSizeSamples/nEpochsMax;
    minEpochDurationSamples = lcm(cycleSizeSamplesPresent(1), cycleSizeSamplesPresent(2));
    freqsPresentHz_2F = freqsPresentHz;
    % workaround for only one frequency present
    if( numel(freqsPresentHz) == 1)
        freqsPresentHz_2F = [freqsPresentHz, freqsPresentHz];
    end

    % compute nF1, nF2 frequencies
    freqsSplitHz_nF1 = freqsPresentHz_2F(1):freqsPresentHz_2F(1):DAQ_Rate/2;
    freqsSplitHz_nF2 = freqsPresentHz_2F(2):freqsPresentHz_2F(2):DAQ_Rate/2;

    %  compute nF1, nF2 periods
    
    filteredFreqPeriods_nF1 = floor(freqsSplitHz_nF1*minEpochDurationSamples./DAQ_Rate);
    filteredFreqPeriods_nF2 = floor(freqsSplitHz_nF2*minEpochDurationSamples./DAQ_Rate);
    
    % compute frequency multiples to be used/removed  
    switch harmonicSelection
        case 'nF1'
            filteredFreqPeriods = filteredFreqPeriods_nF1;
        case 'nF2'
            filteredFreqPeriods = filteredFreqPeriods_nF2;
        case 'nF1clean'
            % multiples of F1 that don't contain multiples of F2
            filteredFreqPeriods = setdiff(filteredFreqPeriods_nF1, filteredFreqPeriods_nF2);            
        case 'nF2clean'
            filteredFreqPeriods = setdiff(filteredFreqPeriods_nF2, filteredFreqPeriods_nF1);
        otherwise
            % custom frequency values
    end
    if (isempty(filteredFreqPeriods))
        disp 'unable to perform filtering'
        return;
    end
    % up to Nyquist Frequency
    filteredFreqPeriodsNq = filteredFreqPeriods(filteredFreqPeriods < round(minEpochDurationSamples/2));

    % for every element in rawData, reshape trial duration nTrialSamples to minEpochDurationSamples x nEpochs 
    resampledDataCell =  cellfun(@(x) reshapeTrialToEpochs(x, minEpochDurationSamples), rawData, ...
        'uni', false);
    
    % filter data
    [cleanSignal, nFSignal] = cellfun(@(x) rcaExtra_filter4DData(x, filteredFreqPeriodsNq), ...
        resampledDataCell, 'uni', false);
    
    % return clean or filtered out data  
    switch filterOperation
        case 'keep'
            dataOut = cellfun(@(x) reshapeEpochsToTrial(x), nFSignal, 'uni', false);
        case 'remove'
            dataOut = cellfun(@(x) reshapeEpochsToTrial(x), cleanSignal, 'uni', false);
        otherwise
    end
end

