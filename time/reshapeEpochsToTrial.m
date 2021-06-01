function dataMatOut =  reshapeEpochsToTrial(dataMatIn)
% function reshapes epoch-level EEG data to trial-level EEG data

%% INPUT ARGUMENTS: 

% 4D double matrix with dimentions epochDurationSamples x nEpochsPerTrial x nChannels x nTrials. 

%% OUTPUT ARGUMENTS: 

% dataMatOut: 3D double matrix with dimentions 
% epochDurationSamples*nEpochsPerTrial x nChannels x nTrials. 

% Alexandra Yakovleva, Stanford University 2021
    [epochDurationSamples, nEpochs, nChannels, nTrials] = size(dataMatIn);
    try
        dataMatOut = squeeze(reshape(dataMatIn, ...
            [epochDurationSamples*nEpochs 1 nChannels nTrials]));
    catch err
        rcaExtra_displayError(err)
        dataMatOut = 0;
    end 
end