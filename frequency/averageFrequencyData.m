function [proj, subj, projectedMeanSubj] = averageFrequencyData(inputData, nBs, nFs)
% Alexandra Yakovleva, Stanford University 2012-2020.    
    nComps = size(inputData{1, 1}, 2);
     
    %% Step 2. Split into Real/Imag components
    [data_Re, data_Im] = getRealImag_byBin(inputData, nBs, nFs, nComps);
    
    % data_X is cell array Subjs x Cnds, each element is 1:nBs x 1:nFs x nTrials  
    % avg project -- subjects's data is merged together and computed weighted average
    % avg subject -- subject's data is averaged separately
    
    %% Step 3. Computed weighted avg across subjects (every subj is a trial)
        
    [avgProj_Re, avgSubj_Re, ~] = averageProject(data_Re, nBs);
    [avgProj_Im, avgSubj_Im, ~] = averageProject(data_Im, nBs);
    
    %% Step 4. Computed weighted avg for subjects
    data_aRe = averageSubjects(data_Re);
    data_aIm = averageSubjects(data_Im);

    %% Step 5. Fit error ellipse for project, compute tcirc for subj data 
    [pValSubj, errSubj] = computeErrorSubj(data_aRe, data_aIm);
    [ampErrP, phaseErrP, ellipse] = computeErrorProj(avgSubj_Re, avgSubj_Im);
    
    %% Step 6. Calc Proj/Subj amplitude and phase 
    [ampProj, phaseProj] = computeAmpPhase(avgProj_Re, avgProj_Im);
    [ampSubj, phaseSubj] = computeAmpPhase(avgSubj_Re, avgSubj_Im);
    
    %% Step 7. Get rid of cells?
    proj = projectProjData(ampProj, phaseProj, ampErrP, phaseErrP);
    proj.avgRe = cat(3, avgProj_Re{:});
    proj.avgIm = cat(3, avgProj_Im{:}); 
    proj.ellipseErr = ellipse;
    proj.subjsRe = cat(3, avgSubj_Re(:, :));
    proj.subjsIm = cat(3, avgSubj_Im(:, :));
    subj = projectSubjData(ampSubj, phaseSubj, errSubj, pValSubj);
    
    %% Step 8. Add projected mean subject data
    try
        projectedMeanSubj = projectSubjectAmplitudes(proj);
        projectedMeanSubj.err = subj.err;
    catch err
        projectedMeanSubj = [];
        projectedMeanSubj.err = [];        
        rcaExtra_displayError(err);
    end
end