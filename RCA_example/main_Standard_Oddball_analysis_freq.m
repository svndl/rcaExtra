function main_Standard_Oddball_analysis_freq

    %% define experimentInfo
    
    experimentName = 'Exports_6Hz';
    
    % load up expriment info specified in loadExperimentInfo_experimentName
    % matlab file
    
    try
        analysisStruct = feval(['loadExperimentInfo_' experimentName]);
    catch err
        % in case unable to load the designated file, load default file
        % (not implemented atm)
        disp('Unable to load specific expriment settings, loading default');
        analysisStruct = loadExperimentInfo_Default;
    end
    
    % specified for general data loader and plotting, currently not used
    analysisStruct.domain = 'freq';
    loadSettings = rcaExtra_getDataLoadingSettings(analysisStruct);
    
    % read raw data 
    [subjList, EEGData] = getRawData(loadSettings);
    rcSettings = rcaExtra_getRCARunSettings(analysisStruct);
    rcSettings.subjList = subjList;
    
    %% reading source data for training and projecting
    
    settings_f_all_rca = info;
    settings_f_all_rca.useBins = 0;
    settings_f_all_rca.useFrequencies = cat(2, info.frequencyLabels{:});
    
    settings_f_all_raw = info;
    settings_f_all_raw.useBins = info.bins;
    settings_f_all_raw.useFrequencies = cat(2, info.frequencyLabels{:});
   
    % read avg bin (0) for RC training F1 
    % [subjList, sensorData_f1_rc, cellNoiseData1_f1, cellNoiseData2_f1, info_f1] = readRawEEG_freq(settings_f1_rca);
    
     % read avg bin (0) for RC training F1, F2 
    [subjList, sensorData_f_rc, cellNoiseData1_f, cellNoiseData2_f, info_f] = readRawEEG_freq(settings_f_all_rca);
    [~, sensorData_f_raw, ~, ~, ~] = readRawEEG_freq(settings_f_all_raw);
    
    % example reading F2 avg data 
    % [~, sensorData_f2_rc, cellNoiseData1_f2, cellNoiseData2_f2, info_f2] = readRawEEG_freq(info, settings_f2_rca);    
    
    % read raw data for averaging F1 (don't need noise/info)
    % [~, sensorData_f1_raw, ~, ~, info_f1_raw] = readRawEEG_freq(settings_f1_raw);    
     
    % example reading F2 raw data 
    %     [~, sensorData_f2_raw, ~, ~, info_f2_raw] = readRawEEG_freq(info, settings_f2_raw);
    %     [~, sensorData_f2_rc, cellNoiseData1_f2, cellNoiseData2_f2, info_f2] = readRawEEG_freq(info, settings_f2_rca);
    %     [~, sensorData_f2_raw, ~, ~, info_f2_raw] = readRawEEG_freq(info, settings_f2_raw);
        
    %% Setting up RC analysis, common variables 
    rcaSettings.subjList = subjList; % store subjects
    rcaSettings.binIndices = info_f.indB; % available bins
    rcaSettings.binsToUse = 0; % bins used for training
    rcaSettings.trialsToUse = []; % use all trials
    rcaSettings.nReg = 7; 
    rcaSettings.nComp = 6;
    rcaSettings.chanToCompare = 75; % oz channel to include in plotting (can be defined as a vector of channels)
    rcaSettings.computeComparison = 0; % outdated
    rcaSettings.binLevels = info_f.binLabels; % labels for bins
    rcaSettings.dataType = 'RLS'; 
    rcaSettings.rcPlotStyle =  'matchMaxSignsToRc1'; 
    runDate = datestr(clock,26); 
    runDate(strfind(runDate,'/')) ='';
    rcaSettings.runDate = runDate; % runtime info
    
    % customize options
    rcaSettings_all = rcaSettings;
    freqs_to_use_c1_f = [1 2 3 4 5 6];
    rcaSettings_all.freqIndices = info_f.indF(freqs_to_use_c1_f); % available frequencies
    rcaSettings_all.freqsToUse = freqs_to_use_c1_f; % frequencies used for traiing
    rcaSettings_all.freqLabels = info_f.freqLabels(freqs_to_use_c1_f); % labels for frequencies

    
    % specifying template settings structure for f1 or f2 RCA 
    % freqs_to_use_c1_f1 = [1 2 3 4]; % freq multiples to use for training
    % freqs_to_use_c1_f2 = [1 2];
        
    % allocating space for rcAnalysis
    nConditions = numel(info.conditionLabels);
    rcaStrct = cell(nConditions, 1);
    projected_Conditions_rc = cell(nConditions, 1);
    projected_Conditions_Subj_rc = cell(nConditions, 1);
    
    
    % store each condition's weight matrix individually
    W_rc_ch = cell(nConditions, 1);
    close all;
    
    for nc = 1:nConditions
        % copy RC template settings for each condition and modify if needed
        
        rcaSettings_cnd_f = rcaSettings_all;
        rcaSettings_cnd_f.condsToUse = 1;
        
        % specify electrdode channels to extract for comparision
        rcaSettings_cnd_f.chanToCompare = rcaSettings_all.chanToCompare;
        
        % total number of plots (RCs + additional channels), can be
        % different for each condition
        nTotalComp = rcaSettings_all.nComp + numel(rcaSettings_all.chanToCompare);
        
        % specify save file
        rcaSettings_cnd_f.savedFile = [info.destDataDir_RCA filesep 'rcaResults_Frequency_c' num2str(nc) '_f1f2.mat'];
        
        % select condition data from avg bin data subset
        cData = sensorData_f_rc(:, nc)';
        cNoise1 = cellNoiseData1_f(:, nc)';
        cNoise2 = cellNoiseData2_f(:, nc)';
        
        % run RCA
        rcaStrct{nc} = rcaRun_frequency(cData, cNoise1, cNoise2, rcaSettings_cnd_f);
        
        % select raw data (all bins) subset 
        cRawData = sensorData_f_raw(:, nc);
        
        % concat RC and channel(s) weights for plotting/comparision
        % create weight matrix for additional electrode channels to plot
        W_ch = zeros(128, numel(rcaSettings_cnd_f.chanToCompare));    
        W_ch(rcaSettings_cnd_f.chanToCompare, 1) = 1;
        W_rc_ch{nc} = cat(2, rcaStrct{nc}.W, W_ch);
        
        % run weighted averaging 
        [projected_Conditions_rc{nc}, projected_Conditions_Subj_rc{nc}] = ...
            averageFrequencyData(cRawData', numel(info.bins), numel(freqs_to_use_c1_f), W_rc_ch{nc});
        
        % add topographies for plotting 
        projected_Conditions_rc{nc}.A = rcaStrct{nc}.A;
        
        % add condition label
        projected_Conditions_rc{nc}.label = info.conditionLabels{nc};
        
        % test significance against zero
        stats_info = getBetweenConditionsStats(cRawData', numel(info.bins), numel(freqs_to_use_c1_f1), W_rc_ch{nc}); 
        
        % add stat info to data sructure
        projected_Conditions_rc{nc}.stats = stats_info;
        
        % create text labels for RC and individual channels 
        rc_Labels = arrayfun(@(x) strcat('RC', num2str(x)), 1:rcaSettings_f1.nComp, 'uni', false);
        ch_Labels = arrayfun(@(x) strcat('CH ', num2str(x)), rcaSettings_f1.chanToCompare(:), 'uni', false);
        projected_Conditions_rc{nc}.compLabels = [rc_Labels, ch_Labels];
        
        % plot summary for each RC/channel: topo, amplitude, frequency, significance     
        gcf_cnd_rcs = plotConditionSummaryGroup_freq(info.frequencies(1), projected_Conditions_rc{nc});
        
        % name figures
        saveFigsStr = strcat(domain, '_rca_summary_Condition_', info.conditionLabels{nc}, '_Comp_');
        saveFigStr_rcs = arrayfun(@(x) strcat(saveFigsStr, num2str(x), '.fig'), 1:nTotalComp, 'uni', false);
        % save figures
        cellfun(@(x, y) saveas(x, fullfile(info.destDataDir_FIG, y)), gcf_cnd_rcs, saveFigStr_rcs', 'uni', false); 
    end
    
    %% comparing two conditions
    close all;
    % define condition to compare with
    cmpCnd = 1;
    
    for nc = 2:nConditions
        % test one condition against all others
        stats_info_c1 = getBetweenConditionsStats(sensorData_f1_raw(:, [cmpCnd nc])', numel(info.bins), numel(freqs_to_use_c1_f1), W_rc_ch{nc});
        nTotalComp = size(W_rc_ch{nc}, 2);
        
        %% plot summary for each condition: RC topo, amplitude, frequency, significance
        gcf_cnd_rcs = plotConditionComparitionTwoGroups_freq(info.frequencies(1), ...
            {projected_Conditions_rc{cmpCnd}, projected_Conditions_rc{nc}}, stats_info_c1);
        saveFigsStr = strcat(domain, '_rca_ComparingConditions_', info.conditionLabels{cmpCnd}, '_', info.conditionLabels{nc}, '_Comp_');
        saveFigStr_rcs = arrayfun(@(x) strcat(saveFigsStr, num2str(x), '.fig'), 1:nTotalComp, 'uni', false);
        cellfun(@(x, y) saveas(x, fullfile(info.destDataDir_FIG, y)), gcf_cnd_rcs, saveFigStr_rcs', 'uni', false);         
    end
    
    %% plot all conditions

    % needs to have same number of RCs and additional electrode channels
    % for each condition
    close all;
    nTotalComp = rcaSettings_f1.nComp + numel(rcaSettings_f1.chanToCompare);
    % 
    [bars_all, lolli_all] =  arrayfun(@(x) plotGroups_freq(info.frequencies(1), info.conditionLabels, projected_Conditions_rc{:}, x), ...
        1:nTotalComp, 'uni', false);
    
    % naming figures
    saveFigsStr_bars = strcat(domain, '_rca_summary_Conditions_ALL_bars', '_Comp_');
    saveFigsStr_loli = strcat(domain, '_rca_summary_Conditions_ALL_lolli', '_Comp_');
    saveFigStr_bars_rcs = arrayfun(@(x) strcat(saveFigsStr_bars, num2str(x), '.fig'), 1:nTotalComp, 'uni', false);
    saveFigStr_loli_rcs = arrayfun(@(x) strcat(saveFigsStr_loli, num2str(x), '.fig'), 1:nTotalComp, 'uni', false);
    % saving figures
    cellfun(@(x, y) saveas(x, fullfile(info.destDataDir_FIG, y)), bars_all, saveFigStr_bars_rcs, 'uni', false);
    cellfun(@(x, y) saveas(x, fullfile(info.destDataDir_FIG, y)), lolli_all, saveFigStr_loli_rcs, 'uni', false);
end