function dataMatOut =  reshapeTrialToEpochs(dataMatIn, epochDurationSamples)
% function reshapes trial-level EEG data to epoch-level EEG data

%% INPUT ARGUMENTS: 

% dataMatIn: 3D double matrix with dimentions 
% nTrialDurationSamples x nChannels x nTrials. 
%
% 
% epochDurationSamples: duration of epochs, should be less than nTrialDurationSamples
% should be integer divisor for of nTrialDurationSamples

%% OUTPUT ARGUMENTS: 

% dataMatOut: 4D double matrix with dimentions 
% epochDurationSamples x nEpochsPerTrial x nChannels x nTrials. 

% Alexandra Yakovleva, Stanford University 2021

    [trialDurationSamples, nChannels, nTrials] = size(dataMatIn);
    nEpochs = floor(trialDurationSamples/epochDurationSamples);
    try
        dataMatOut = reshape(dataMatIn, ...
            [epochDurationSamples nEpochs nChannels nTrials]);
    catch err
        rcaExtra_displayError(err)
        dataMatOut = 0;
    end
end