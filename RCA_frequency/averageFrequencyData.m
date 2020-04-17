function [proj, subj] = averageFrequencyData(inputData, nBs, nFs, W)
% Alexandra Yakovleva, Stanford University 2012-2020.
    nChs =  size(W, 1);
    nComps = size(W, 2);
    
    %% Step 1. Project to reduce dims
    projData = projectData(inputData, W);
    
    %% Step 2. Split into Real/Imag components
    [data_Re, data_Im] = getRealImag_byBin(projData, nBs, nFs, nComps);
    
    % data_X is cell array Cnds x Subjs, each element is 1:nBs x 1:nFs x nTrials  
    % avg project -- subjects's data is merged together and computed weighted average
    % avg subject -- subject's data is averaged separately
    
    %% Step 3. Computed weighted avg across subjects (every subj is a trial)
    
    [avgProj_Re, avgSubj_Re, ~] = averageProject(data_Re, nBs);
    [avgProj_Im, avgSubj_Im, ~] = averageProject(data_Im, nBs);
    
    %% Step 4. Computed weighted avg for subjects
    data_aRe = averageSubjects(data_Re);
    data_aIm = averageSubjects(data_Im);

    %% Step 5. Fit error ellipse for project and subject data 
    errSubj = computeErrorSubj(data_aRe, data_aIm);
    [ampErrP, phaseErrP, ellipse] = computeErrorProj(avgSubj_Re, avgSubj_Im);
    
    %% Step 6. Calc Proj/Subj amplitude and phase 
    [ampProj, phaseProj] = computeAmpPhase(avgProj_Re, avgProj_Im);
    [ampSubj, phaseSubj] = computeAmpPhase(avgSubj_Re, avgSubj_Im);
    
    %% Step 7. Get rid of cells?
    proj = projectProjData(ampProj, phaseProj, ampErrP, phaseErrP);
    proj.ellipseErr = ellipse;
    proj.subjsRe = cat(3, avgSubj_Re(:, :)');
    proj.subjsIm = cat(3, avgSubj_Im(:, :)');
    subj = projectSubjData(ampSubj, phaseSubj, errSubj);    
end
function [data_re, data_im] = getRealImag_byBin(inputData, nBins, nFreqs, nChs)
    [data_cos, data_sin] = getRealImag(inputData);
    data_re = cellfun(@(x) reshape(x, [nBins nFreqs nChs size(x, 3)]), data_cos, 'uni', false);
    data_im = cellfun(@(x) reshape(x, [nBins nFreqs nChs size(x, 3)]), data_sin, 'uni', false);
end