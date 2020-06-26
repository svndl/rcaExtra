function [avgSubj_Re, avgSubj_Im] = averageSubjectFrequencyData(inputData, nBs, nFs, W)

    nComps = size(W, 2);
    
    %% Step 1. Project to reduce dims
    projData = projectData(inputData, W);
    
    %% Step 2. Split into Real/Imag components
    [data_Re, data_Im] = getRealImag_byBin(projData, nBs, nFs, nComps);
    
    % data_X is cell array Cnds x Subjs, each element is 1:nBs x 1:nFs x nTrials  
    % avg project -- subjects's data is merged together and computed weighted average
    % avg subject -- subject's data is averaged separately
    
    %% Step 3. Computed weighted avg across subjects (every subj is a trial)
    
    [~, avgSubj_Re, ~] = averageProject(data_Re, nBs);
    [~, avgSubj_Im, ~] = averageProject(data_Im, nBs);    
end