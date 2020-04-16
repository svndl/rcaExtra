function new_Standard_Oddball_analysis

    %% define experimentInfo
    
    experimentName = 'Exports_6Hz';
    try
        info = feval(['loadExperimentInfo_' experimentName]);
    catch err
        disp('Unable to load specific expriment settings, loading default');
        info = loadExperimentInfo_Default;
    end
    
    domain = 'freq';   
    %% RCA training settings
       
    settings_f2_rca.useFrequencies = info.frequencyLabels{2};
    settings_f2_rca.subjTag = info.subjTag; 
    
    settings_f2_raw.useFrequencies = info.frequencyLabels{2};
    settings_f2_raw.subjTag = info.subjTag;
    settings_f2_raw.useBins = info.bins;
    
    settings_f1_raw.useFrequencies = info.frequencyLabels{1};
    settings_f1_raw.subjTag = info.subjTag;
    settings_f1_raw.useBins = info.bins;
    
    
    settings_f1_rca = settings_f1_raw;
    settings_f1_rca.useBins = 0;
    settings_f1_rca.useFrequencies = info.frequencyLabels{1};
    
    %% read bin 0  for RC weights
    [subjList, sensorData_f1_rc, cellNoiseData1_f1, cellNoiseData2_f1, info_f1] = readselectiveDFTData(info, settings_f1_rca);    
    [~, sensorData_f2_rc, cellNoiseData1_f2, cellNoiseData2_f2, info_f2] = readselectiveDFTData(info, settings_f2_rca);    
    
    %% read raw data for averaging
    [~, sensorData_f1_raw, ~, ~, info_f1_raw] = readselectiveDFTData(info, settings_f1_raw);    
    [~, sensorData_f2_raw, ~, ~, info_f2_raw] = readselectiveDFTData(info, settings_f2_raw);    
    
%     [~, sensorData_f2_rc, cellNoiseData1_f2, cellNoiseData2_f2, info_f2] = readselectiveDFTData(info, settings_f2_rca);    
%     [~, sensorData_f2_raw, ~, ~, info_f2_raw] = readselectiveDFTData(info, settings_f2_raw);    
        
    %%
    
    freqs_to_use_c1_f2 = [1 2];
    freqs_to_use_c1_f1 = [1 2 3 4];
    
    rcaSettings_f1.subjList = subjList;
    rcaSettings_f1.freqIndices = info_f1.indF(freqs_to_use_c1_f1); % train on 1f1, 2f1
    rcaSettings_f1.binIndices = info_f1.indB; % train on 1f1, 2f1
    rcaSettings_f1.binsToUse = 0;
    rcaSettings_f1.freqsToUse = freqs_to_use_c1_f1; % train on 1f1, 2f1
    rcaSettings_f1.trialsToUse = [];
    rcaSettings_f1.nReg = 7;
    rcaSettings_f1.nComp = 4;
    rcaSettings_f1.chanToCompare = 76;
    rcaSettings_f1.freqLabels = info_f1.freqLabels(freqs_to_use_c1_f1);
    rcaSettings_f1.computeComparison = 0;
    rcaSettings_f1.binLevels = info_f1.binLabels;
    rcaSettings_f1.dataType = 'RLS';
    rcaSettings_f1.rcPlotStyle =  'matchMaxSignsToRc1';
    runDate = datestr(clock,26);
    runDate(strfind(runDate,'/')) ='';
    rcaSettings_f1.runDate = runDate;
    
    
    nConditions = numel(info.conditionLabels);
    rcaStrct = cell(nConditions, 1);
    projected_Conditions_rc = cell(nConditions, 1);
    projected_Conditions_Subj_rc = cell(nConditions, 1);
    
    chOZ = 75;
    W_OZ = zeros(128, 1);
    W_OZ(chOZ, 1) = 1;
    
    for nc = 1:nConditions
        rcaSettings_cnd_f1 = rcaSettings_f1;
        rcaSettings_cnd_f1.condsToUse = 1;
        rcaSettings_cnd_f1.savedFile = [info.destDataDir_RCA filesep 'rcaResults_Frequency_c' num2str(nc) '_f1.mat'];
        rcaSettings_cnd_f1.chanToCompare = chOZ;
        cData = sensorData_f1_rc(:, nc)';
        cNoise1 = cellNoiseData1_f1(:, nc)';
        cNoise2 = cellNoiseData2_f1(:, nc)';
        rcaStrct{nc} = rcaRun_frequency(cData, cNoise1, cNoise2, rcaSettings_cnd_f1);
        cRawData = sensorData_f1_raw(:, nc);
        [projected_Conditions_rc{nc}, projected_Conditions_Subj_rc{nc}] = ...
            averageFrequencyData(cRawData', numel(info.bins), numel(freqs_to_use_c1_f1), rcaStrct{nc}.W);
        projected_Conditions_rc{nc}.A = rcaStrct{nc}.A;
        projected_Conditions_rc{nc}.label = info.conditionLabels{nc};
        %% t2 against zero
        stats_info = getBetweenConditionsStats(cRawData', numel(info.bins), numel(freqs_to_use_c1_f1), rcaStrct{nc}.W); 
        projected_Conditions_rc{nc}.stats = stats_info;
        
        %% plot summary for each condition/RC topo, amplitude, frequency, significance     
        
        gcf_cnd_rcs = plotConditionSummaryGroup_freq(info.frequencies(1), projected_Conditions_rc{nc});
        saveFigsStr = strcat('rca_summary_Condition_', info.conditionLabels{nc}, '_RC_');
        saveFigStr_rcs = arrayfun(@(x) strcat(saveFigsStr, num2str(x), '.fig'), 1:rcaSettings_f1.nComp, 'uni', false);
        cellfun(@(x, y) saveas(x, fullfile(info.destDataDir_FIG, y)), gcf_cnd_rcs, saveFigStr_rcs', 'uni', false); 
    end
    
    %% comparing conditions
    cmpCnd = 1;
    for nc = 2:nConditions
        %% t2 against zero
        stats_info_c1 = getBetweenConditionsStats(sensorData_f1_raw(:, [cmpCnd nc])', numel(info.bins), numel(freqs_to_use_c1_f1), rcaStrct{nc}.W);
        %% plot summary for each condition: RC topo, amplitude, frequency, significance
        gcf_cnd_rcs = plotConditionComparitionTwoGroups_freq(info.frequencies(1), ...
            {projected_Conditions_rc{cmpCnd}, projected_Conditions_rc{nc}}, stats_info_c1);
        saveFigsStr = strcat('rca_summary_ConditionCMP_', info.conditionLabels{cmpCnd}, '_', info.conditionLabels{nc}, '_RC_');
        saveFigStr_rcs = arrayfun(@(x) strcat(saveFigsStr, num2str(x), '.fig'), 1:rcaSettings_f1.nComp, 'uni', false);
        cellfun(@(x, y) saveas(x, fullfile(info.destDataDir_FIG, y)), gcf_cnd_rcs, saveFigStr_rcs', 'uni', false);         
    end
    
    %% plot all conditions
    
    [bars_all, lolli_all] =  arrayfun(@(x) plotGroups_freq(info.frequencies(1), info.conditionLabels, projected_Conditions_rc{:}, x), ...
        1:rcaSettings_f1.nComp, 'uni', false);
    saveFigsStr_bars = strcat('rca_summary_Conditions_ALL_bars', info.conditionLabels{cmpCnd}, '_', info.conditionLabels{nc}, '_RC_');
    saveFigsStr_loli = strcat('rca_summary_Conditions_ALL_bars', info.conditionLabels{cmpCnd}, '_', info.conditionLabels{nc}, '_RC_');
    saveFigStr_bars_rcs = arrayfun(@(x) strcat(saveFigsStr_bars, num2str(x), '.fig'), 1:rcaSettings_f1.nComp, 'uni', false);
    saveFigStr_loli_rcs = arrayfun(@(x) strcat(saveFigsStr_loli, num2str(x), '.fig'), 1:rcaSettings_f1.nComp, 'uni', false);
    
    cellfun(@(x, y) saveas(x, fullfile(info.destDataDir_FIG, y)), bars_all, saveFigStr_bars_rcs, 'uni', false);
    cellfun(@(x, y) saveas(x, fullfile(info.destDataDir_FIG, y)), lolli_all, saveFigStr_loli_rcs, 'uni', false);
end
