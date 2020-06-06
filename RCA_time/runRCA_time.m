function rcResult = runRCA_time(rcaSettings, dataIn)
    
    % resample data if needed
    resampled_data = dataIn;
    if (size(dataIn{1, 1}, 1) ~= rcaSettings.samplingRate)
        resampled_data = resampleData(dataIn, rcaSettings.samplingRate);
    end
    if (~isempty(rcaSettings.useCnds))
        dataSlice = resampled_data(:, rcaSettings.useCnds);
    else
        dataSlice = resampled_data;
    end
    disp(['Running RC on ' rcaSettings.label ' dataset']);    
    matFileRCA = fullfile(rcaSettings.destDataDir_RCA, ['rcaResults_Time_' rcaSettings.label '.mat']);
    
    %% run RCA
     
    delete(gcp('nocreate'));
    
    % if file doesn't exst, run analysis and save results
    if(~exist(matFileRCA, 'file'))
        [rcaData, W, A, Rxx, Ryy, Rxy, dGen, ~] = rcaRun(dataSlice', rcaSettings.nReg, rcaSettings.nComp);
        runSettings = rcaSettings;
        save(matFileRCA, 'rcaData', 'W', 'A', 'Rxx', 'Ryy', 'Rxy', 'dGen', 'runSettings');
        % add title to figures
        
        saveas(gcf, fullfile(rcaSettings.destDataDir_FIG, ['RCA_' rcaSettings.label '.fig']));
        saveas(gcf, fullfile(rcaSettings.destDataDir_FIG, ['RCA_' rcaSettings.label '.png']));        
    else
    % if file exists, load the data, weights, settings    
        disp(['Loading weights from ' matFileRCA]);
        load(matFileRCA, 'rcaData', 'W', 'A', 'Rxx', 'Ryy', 'Rxy', 'dGen', 'runSettings');
        % compare runtime settings and subjects list
        if (~rcaExtra_compareRCASettings_time(rcaSettings, runSettings))
            % if settings don't match, save old file and re-run the analysis
            
            disp('New settings don''t match previous instance, re-running RCA ...'); 
            matFileRCA_old = fullfile(rcaSettings.destDataDir_RCA, ['previous_rcaResults_Time_' rcaSettings.label '.mat']);
            movefile(matFileRCA ,matFileRCA_old, 'f')
            
            [rcaData, W, A, ~, ~, ~, ~] = rcaRun(dataSlice, rcaSettings.nReg, rcaSettings.nComp);
            runSettings = rcaSettings;
            save(matFileRCA, 'rcaData', 'W', 'A', 'Rxx', 'Ryy', 'Rxy', 'dGen', 'runSettings');
        end
        
        %% dealing with previous versions of RC files
        
        % add projected data
        if (~exist('rcaData', 'var'))
            try
                rcaData = rcaProject(dataSlice, W);
                save(matFileRCA, 'rcaData', 'W', 'A', 'Rxx', 'Ryy', 'Rxy', 'dGen');
            catch err
                disp('could not project Subjects, results not modified');
                rcaData = dataSlice;
            end
        end
        % add settings
        if (~exist('runSettings', 'var'))
            % implement proper storage/loading: if there are no settings,
            % re-run and store
            runSettings = settings;
            try
                save(matFileRCA, 'rcaData', 'W', 'A', 'Rxx', 'Ryy', 'Rxy', 'dGen', 'runSettings');
            catch err
                disp('could not add settings, results not modified');
            end
        end
    end
    
    %% 
    tc = linspace(0, rcaSettings.timecourseLen - 1, rcaSettings.samplingRate);
    
    % compute stats
    statSettings = rcaExtra_getStatsSettings(rcaSettings);
    subjRCMean = rcaExtra_prepareDataArrayForStats(rcaData', statSettings);
    sigResults = rcaExtra_testSignificance(subjRCMean, [], statSettings);
    %% plot rc results 
    try
        rcPlot_time(rcaData, tc, A, sigResults, Rxx, Ryy, dGen);
        parentFig = get(gca, 'Parent');
        parentFig.Name = rcaSettings.label;            
    catch err
        % Rxx, Ryy, dGen not available
        rcPlot_time(rcaData, tc, A, sigResults, [], [], []);
        parentFig = get(gca, 'Parent');
        parentFig.Name = rcaSettings.label;       
    end
    
    saveas(gcf, fullfile(rcaSettings.destDataDir_FIG, ['RCA_' rcaSettings.label '.fig']));
    saveas(gcf, fullfile(rcaSettings.destDataDir_FIG, ['RCA_' rcaSettings.label '.png']));
    
    %% compute mean and deviations for each projected condition and for all
    
    % average each subject's response
    subjMean_cell = cellfun(@(x) nanmean(x, 3), rcaData, 'uni', false)';
    nCnd = size(subjMean_cell, 2);
    subjMean_bycnd = cell(1, nCnd);
    for nc = 1:nCnd
         cndData = cat(3, subjMean_cell{:, nc});
         % baseline
         subjMean_bycnd{nc} = cndData - repmat(cndData(1, :, :), [size(cndData, 1) 1 1]);
    end
    
    % store results
    rcResult.sourceData = dataSlice; % (not sure if we should store it ...)
    rcResult.W = W;
    rcResult.A = A;
    rcResult.timecourse = tc;
    rcResult.projectedData = rcaData'; % corrected to nSubj x nCnd dimentions
    
    % for joint projection, compute mean/std
    subjMean = squeeze(cat(3, subjMean_bycnd{:}));    
    rcResult.mu = nanmean(subjMean, 3);
    rcResult.s = nanstd(subjMean, [], 3)/(sqrt(size(subjMean, 3)));
    
    % for each condition, compute individual mean/std
    rcResult.mu_cnd = cellfun(@(x) nanmean(x, 3), subjMean_bycnd, 'uni', false);
    rcResult.s_cnd = cellfun(@(x) nanstd(x, [], 3)/(sqrt(size(x, 3))), subjMean_bycnd, 'uni', false);
end