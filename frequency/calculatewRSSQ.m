function [subjRSSQ, subjWeights] = calculatewRSSQ(inputData, nBs, nFs)
% returns subjects's RSSQ and assosiated weights
% INPUT 
% inputData is a 2D cell matrix of nSubjects x nConditions, 
% each element is 2*nBs*nFs x nComponents x nTrials

% nBs number of bins
% nFs number of frequencies

% OUTPUT
% [subjRSS, subjWeights]

% subjRSSQ is a 3D data matrix of nSubjs x nCnds x nComp, each element is
% rssq of nF amplitudes

% subjWeights is a weight 2D data matrix with total included values for
% each subj and condition

    nComps = size(inputData{1, 1}, 2);
    [nSubj, nCnds] = size(inputData);
    %% Step 2. Split into Real/Imag components
    [data_Re, data_Im] = getRealImag_byBin(inputData, nBs, nFs, nComps);
 
    [~, avgSubj_Re, w_re] = averageProject(data_Re, nBs);
    [~, avgSubj_Im, ~] = averageProject(data_Im, nBs);

    %% same weights for real, imaginary, RC, harmonic multiples 
    subjWeights = cellfun(@(x) mean(squeeze(mean(x, 2)), 1), w_re, 'Uni', true);
    
    
    %% compute amplitude for each subject
   
    [ampSubj, ~] = computeAmpPhase(avgSubj_Re, avgSubj_Im);
    
    %% compute RSS (sqrt(sum(sqr()))) for each subject
    cell_RSSQSubj = cellfun(@(x) rssq(x, 1), ampSubj', 'uni', false);
    
    % convert to array
    temp3DMat = reshape(cell2mat(cell_RSSQSubj), [nSubj nComps nCnds]);
    % move components into last dimention
    subjRSSQ = permute(temp3DMat, [1, 3, 2]);
end