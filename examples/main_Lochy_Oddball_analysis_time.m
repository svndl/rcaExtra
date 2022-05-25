function main_Lochy_Oddball_analysis_time

    %% define experimentInfo
          
    experimentName = 'Lochy_Oddball';
    
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
    analysisStruct.domain = 'time';
    loadSettings = rcaExtra_getDataLoadingSettings(analysisStruct);
    
    % read raw data 
    [subjList, EEGData] = getRawData(loadSettings);
    rcSettings = rcaExtra_getRCARunSettings(analysisStruct);
    rcSettings.subjList = subjList;
       
    % selecting specific frequency (1 HZ) and corresponding sampling rate
    % and time course length to use for resampling, RC analysis and
    % plotting results

    % not going to work because 1F1 = 6F2
%     data_nF2 = rcaExtra_filterData(EEGData, analysisStruct.info.frequenciesHz, 'nF2', 'keep');
    
    % rcSettings has two resampling values and two timecourses
    
    runSettings_2hz = rcSettings;
    runSettings_2hz.cycleLength = rcSettings.cycleLength(1);
    runSettings_2hz.cycleDuration = rcSettings.cycleDuration(1);
    
    
    nConditions = size(EEGData, 2);
    % allocate cell array to store individual condition RCA runtime settings 
    runSettings_1hz_condition = cell(nConditions, 1);
    
    % allocate cell array to store individual condition RCA runtime results     
    rcResult_condition = cell(nConditions, 1);
    
    % run RC analysis for each condition
%     for nc = 1:nConditions
%         % copy runtime settings from 1Hz template
%         runSettings_1hz_condition{nc} = runSettings_1hz;
%         runSettings_1hz_condition{nc}.useCnds = nc;
%         % add condition-specific label 
%         runSettings_1hz_condition{nc}.label = analysisStruct.info.conditionLabels{nc};
%         
%         % select subset of raw data        
%         rcResult_condition{nc} = rcaExtra_runAnalysis(runSettings_1hz_condition{nc}, EEGData);
%     end
    
    
    % run RC on all conditions and project
    runSettings_2hz.label = 'Conditions_1-4';
    
    % demonstrate that RCA result has 6Hz present in and not informative
    runSettings_2hz.computeStats = 0;
    runSettings_2hz.useCnds = 1:4;
    rcResult_all = rcaExtra_runAnalysis(runSettings_2hz, EEGData);
    
    % filter out 6Hz
    data_nF1 = rcaExtra_filterData(EEGData, analysisStruct.info.frequenciesHz, 'nF1clean', 'keep');    
    
    runSettings_2hz_clean = runSettings_2hz;
    runSettings_2hz_clean.label = 'Conditions_1-4_nF1_clean';

    rcResult_all_nF1_clean = rcaExtra_runAnalysis(runSettings_2hz_clean, data_nF1);
    
    % flip weights, use once
    %rcResult_all_nF1_clean = rcaExtra_adjustRCWeights(rcResult_all_nF1_clean, [-1 2 3 4 5 6]);
    
    % plot conditions
    
    % colors, make sure to have enough for each condition
    load('colorbrewer');
    
    colors_to_use = colorbrewer.qual.Set1{8};
        
    %% plotting
    rcResult_all_nF1_clean.rcaSettings.computeStats = 0;

    plot_1hz_all = rcaExtra_initPlottingContainer(rcResult_all_nF1_clean);
    plot_1hz_all.conditionLabels = analysisStruct.info.conditionLabels;
    plot_1hz_all.rcsToPlot = 1;
    plot_1hz_all.cndsToPlot = 1:4;
    plot_1hz_all.conditionColors = colors_to_use./255;
    % plots groups, each condition in separate window
    rcaExtra_plotWaveforms(plot_1hz_all)
    
    %split data to be displayed in one figure
    [c1_rc, c2_rc, c3_rc, c4_rc]  = rcaExtra_splitPlotDataByCondition(plot_1hz_all);
    rcaExtra_plotWaveforms(c1_rc, c2_rc, c3_rc, c4_rc);
    

%     %% merging two conditions
%     data_nF1_clean_c12 = rcaExtra_mergeDatasetConditions(data_nF1, [1, 2]);
%     rcResult_c12_nF1_clean = rcResult_all_nF1_clean;
%     rcResult_c12_nF1_clean.label = 'Conditions_1-2_nF1_clean';
%     rcResult_c12_nF1_clean.useCnds = [1 2];
%     rcResult_c12_nF1_clean = rcaExtra_runAnalysis(runSettings_2hz_clean, data_nF1_clean_c12);
%     
%     %% projecting conditions 3, 4 through weights
%     projected_c34_nF1_clean = projectDatasets(rcResult_c12_nF1_clean.W, data_nF1(:, 3), data_nF1(:, 4));
    
    %% Averaging at Sensor Data
    avgSensor_all = averageSensor_time(rcResult_all_nF1_clean.rcaSettings, data_nF1);
    plot_ch_65 = rcaExtra_initPlottingContainer(avgSensor_all);
    plot_ch_65.conditionLabels = plot_1hz_all.conditionLabels;
    plot_ch_65.rcsToPlot = 65;
    plot_ch_65.cndsToPlot = [1 2 3 4];
    plot_ch_65.conditionColors = colors_to_use./255;
    [c1_s, c2_s, c3_s, c4_s] = rcaExtra_splitPlotDataByCondition(plot_ch_65);
    rcaExtra_plotWaveforms(c1_s, c2_s, c3_s, c4_s);
    
        
end
