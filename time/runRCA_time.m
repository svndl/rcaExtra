function rcaResult = runRCA_time(currSettings, dataIn)
    
    % resample data if needed
    resampled_data = dataIn;
    if (size(dataIn{1, 1}, 1) ~= currSettings.samplingRate)
        resampled_data = resampleData(dataIn, currSettings.samplingRate);
    end
    if (~isempty(currSettings.useCnds))
        dataSlice = resampled_data(:, currSettings.useCnds);
    else
        dataSlice = resampled_data;
    end
    disp(['Running RC on ' currSettings.label ' dataset']);    
    matFileRCA = fullfile(currSettings.destDataDir_RCA, ['rcaResults_Time_' currSettings.label '.mat']);
    tc = linspace(0, currSettings.timecourseLen - 1, currSettings.samplingRate);
    
    %% run RCA
     
    delete(gcp('nocreate'));
    fprintf('Running RCA time for dataset %s number of components: %d ...\n', currSettings.label, currSettings.nComp);
    
    % if file doesn't exst, run analysis and save results
    if(~exist(matFileRCA, 'file'))
        [rcaData, W, A, Rxx, Ryy, Rxy, dGen, ~] = rcaRun(dataSlice', currSettings.nReg, currSettings.nComp);
        
        rcaResult.W = W;
        rcaResult.A = A;
        %rcaResult.sourceData = dataSlice;
        rcaResult.W = W;
        rcaResult.A = A;
        rcaResult.projectedData = rcaData'; % corrected to nSubj x nCnd dimentions
        rcaResult.rcaSettings = currSettings;
        rcaResult.covData.Rxx = Rxx;
        rcaResult.covData.Ryy = Ryy;
        rcaResult.covData.Rxy = Rxy;
        rcaResult.covData.dGen = dGen;
        rcaResult.timecourse = tc;
        save(matFileRCA, 'rcaResult');
    else
    % if file exists, load the data, weights, settings    
        disp(['Loading weights from ' matFileRCA]);
        try
            % new version structure
            load(matFileRCA, 'rcaResult');
            if (~exist('rcaResult', 'var'))
                % load old version structure
                
                % define default values for Rxx, Rxy, Ryy, dGen
                % in older version there variables were not stored
                
                Rxx = [];
                Ryy = [];
                Rxy = [];
                dGen = [];
                
                load(matFileRCA, 'rcaData', 'W', 'A', 'Rxx', 'Ryy', 'Rxy', 'dGen', 'runSettings');
                % loading the old version 
                if (exist('rcaData', 'var'))
                    % create new version struct
                    rcaResult.W = W;
                    rcaResult.A = A;
                    %rcaResult.sourceData = dataSlice;
                    rcaResult.W = W;
                    rcaResult.A = A;
                    rcaResult.projectedData = rcaData'; 
                    rcaResult.rcaSettings = runSettings;
                    rcaResult.covData.Rxx = Rxx;
                    rcaResult.covData.Ryy = Ryy;
                    rcaResult.covData.Rxy = Rxy;
                    rcaResult.covData.dGen = dGen;
                    rcaResult.timecourse = tc;
                    % save old datafile 
                    matFileRCA_old = fullfile(currSettings.destDataDir_RCA, ['oldStruct_rcaResults_Time_' runSettings.label '.mat']);
                    movefile(matFileRCA ,matFileRCA_old, 'f');            
                    % create new data file
                    save(matFileRCA, 'rcaResult');
                end
            end
            % compare runtime settings and subjects list
            if (~rcaExtra_compareRCASettings_time(currSettings, rcaResult.rcaSettings))
                % if settings don't match, save old file and re-run the analysis
            
                disp('New settings don''t match previous instance, re-running RCA ...'); 
                % move old RC results datafile
                matFileRCA_old = fullfile(currSettings.destDataDir_RCA, ['previous_rcaResults_Time_' currSettings.label '.mat']);
                movefile(matFileRCA ,matFileRCA_old, 'f')
                % re-run RC with cirrent settings
                rcaResult = runRCA_time(currSettings, dataIn);
            end
        catch err
            rcaExtra_displayError(err);
            disp('Unable to load weights, re-running the analysis...');
            rcaResult = runRCA_time(currSettings, dataIn);           
        end            
    end
    
    %% copy figures folder
    
    rcaResult.rcaSettings.destDataDir_FIG = currSettings.destDataDir_FIG;
    
    
    %% flip the RC weights here
    %W_new = rcaExtra_adjustRCSigns(rcResults, rcSettings);
    
    % average each subject's response
    subjMean_cell = cellfun(@(x) nanmean(x, 3), rcaResult.projectedData', 'uni', false)';
    nCnd = size(subjMean_cell, 2);
    subjMean_bycnd = cell(1, nCnd);
    for nc = 1:nCnd
         cndData = cat(3, subjMean_cell{:, nc});
         % baseline
         subjMean_bycnd{nc} = cndData - repmat(cndData(1, :, :), [size(cndData, 1) 1 1]);
    end
        
    % for joint projection, compute mean/std
    subjMean = squeeze(cat(3, subjMean_bycnd{:}));    
    rcaResult.mu = nanmean(subjMean, 3);
    rcaResult.s = nanstd(subjMean, [], 3)/(sqrt(size(subjMean, 3)));
    
    % for each condition, compute individual mean/std
    mu_cnd = cellfun(@(x) nanmean(x, 3), subjMean_bycnd, 'uni', false);
    s_cnd = cellfun(@(x) nanstd(x, [], 3)/(sqrt(size(x, 3))), subjMean_bycnd, 'uni', false);
    rcaResult.mu_cnd = cat(3, mu_cnd{:});
    rcaResult.s_cnd = cat(3, s_cnd{:});
    
    % compute stats if required
    sigResults = [];
    if (isfield(currSettings, 'computeStats'))  
        statSettings = rcaExtra_getStatsSettings(currSettings);
        subjRCMean = rcaExtra_prepareDataArrayForStats(rcaResult.projectedData, statSettings);
        sigResults = rcaExtra_testSignificance(subjRCMean, [], statSettings);
    end
    % plot rc results
    try
        rcaExtra_plotRCSummary(rcaResult, sigResults);
    catch err
        rcaExtra_displayError(err);
    end
end