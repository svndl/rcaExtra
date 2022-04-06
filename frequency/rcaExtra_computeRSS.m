function [rssqProjMean, rssqProjStd] = rcaExtra_computeRSS(inputData, nBs, nFs)
%% function computes RSS averages (project, subject) and pairwise factor comparisions 


    nComps = size(inputData{1, 1}, 2);
    nConditions = size(inputData, 2);
    %% Step 2. Split into Real/Imag components
    [data_Re, data_Im] = getRealImag_byBin(inputData, nBs, nFs, nComps);
    
    % data_X is cell array Subjs x Cnds, each element is 1:nBs x 1:nFs x nTrials  
    % avg project -- subjects's data is merged together and computed weighted average
    % avg subject -- subject's data is averaged separately
    
    %% Step 3. Computed weighted avg across subjects (every subj is a trial)
    
    [~, avgSubj_Re, w_re] = averageProject(data_Re, nBs);
    [~, avgSubj_Im, ~] = averageProject(data_Im, nBs);

    %% same weights for real, imaginary, RC, harmonic multiples 
    w0_avg = cellfun(@(x) mean(squeeze(mean(x, 2)), 1), w_re, 'Uni', true);
    
    
    %% compute amplitude for each subject
   
    [ampSubj, ~] = computeAmpPhase(avgSubj_Re, avgSubj_Im);
    
    %% compute RSS (sqrt(sum(sqr()))) mean and standard deviation
    
    cell_RSSQSubj = cellfun(@(x) rssq(x, 1), ampSubj', 'uni', false);
    rssqProjMean = zeros(nConditions, nComps);
    rssqProjStd = zeros(nConditions, nComps);
    for nC = 1:nConditions
        rssqSubjCnd = cat(1, cell_RSSQSubj{:, nC});
        for nRc = 1:nComps
            rssqProjMean(nC, nRc) = wmean(rssqSubjCnd(:, nRc), w0_avg(:, nC));
            rssqProjStd(nC, nRc) = std(rssqSubjCnd(:, nRc), w0_avg(:, nC)/100);
        end
    end
end