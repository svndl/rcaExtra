function [cleanEpochTrialData, filteredTrialData] = rcaExtra_filter4DData(array4D, binIdxFilterVector)
% Function will split input 4D data into two datasets, one without
% frequency components defined in binIdxFilterVector,
% and one with frequency comnponents set in binIdxFilterVector

%
%% INPUT ARGUMENTS
% array4D, raw nSamples x nEpochs x nChannels x nTrials double matrix
% binIdxVector integer vector of bins to use for split, calculated as 
% number of periods for a given frequency in DAQ cycle)

%% OUTPUT ARGUMENTS

% cleanEpochTrialData clean 4D data with same dimentions as the input
% matrix: epochSamples x nEpochs x nChannels x nTrials 
% filteredTrialData filtered data averaged trial epochs: epochSamples x nChannels x nTrials 

% Alexandra Yakovleva, Stanford University 2021


    % determine sizes
    [nSamples, nEpochs, nChannels, nTrials] = size(array4D);   

    % pre-allocate and initiate matrices
    
    cleanEpochTrialData = zeros(nSamples, nEpochs, nChannels, nTrials);
    filteredTrialData = zeros(nSamples, nEpochs, nChannels, nTrials);
    filteredSpectrumTrial = zeros(nSamples, nEpochs, nChannels);
    
    % compute average epoch per channel
    % averageEpoch = squeeze(nanmean(nanmean(array4D, 4), 2));
 
    % operate on trial-to-trial base
    for nt = 1:nTrials
        trialData = squeeze(array4D(:, :, :, nt));
        
        % compute average epoch for each trial
%         averageEpochTrial = squeeze(nanmean(trialData, 2));
%         hasAnyNaNs = sum(isnan(averageEpochTrial(:)));
%         useAverageForFiltering = averageEpochTrial;
%         % if trial has nans
%         if(hasAnyNaNs)
%             % average over all trials
%             useAverageForFiltering = averageEpoch;
%         end
%         % compute FFT2
%         avgSpectrum = fft(useAverageForFiltering);

        % compute FFT2
        epochSpectrum = fft_epoch(trialData);
        % copy values of filtered out bins and
        % mirror-image negative half of the fft output
        
        % Bin 1 is DC
        idxBinsToSeparate = cat(2, 1 + binIdxFilterVector, nSamples - binIdxFilterVector + 1);
        
        % spectrum that only has specified bin values
        filteredSpectrumTrial(idxBinsToSeparate, :, :) = epochSpectrum(idxBinsToSeparate, :, :);
        
        % spectrum that does not have the bin values        
        epochSpectrum(idxBinsToSeparate, :, :) = 0;
        
        % cleaned frequency data in time-domain
        cleanEpochTrialData(:, :, :, nt) = ifft_epoch(epochSpectrum);
        
        % filtered frequencies in time-domain
        filteredTrialData(:, :, :, nt) = ifft_epoch(filteredSpectrumTrial);
%         % subtract data from each epoch
%         cleanEpochTrialData(:, :, :, nt) = trialData - permute(repmat(filteredData, [1 1 nEpochs]), [1 3 2]);       
    end
    
    % plot signals
%     chanelToPlot = 76;
%     
%     avgFilteredSignal = squeeze(nanmean(nanmean(filteredTrialData, 4), 2));
%     avgCleanEpoch = squeeze(nanmean(nanmean(cleanEpochTrialData, 4), 2));
%     figure;
%     
%     plot(squeeze(avgFilteredSignal(:, chanelToPlot)),  '-r', 'LineWidth', 3); hold on;
%     plot(squeeze(avgCleanEpoch(:, chanelToPlot)), '-b', 'LineWidth', 3); hold on;
%     set(gca, 'FontSize', 24);
%     title(strcat ('Channel ', num2str(chanelToPlot)));
%     legend({'Average Filtered', 'Average Epoch Cleaned'});
%     xlabel('Samples, Epoch');
%     ylabel('Amplitude, \muV');
%     