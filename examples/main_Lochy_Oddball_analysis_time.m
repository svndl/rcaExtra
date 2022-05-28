function main_Lochy_Oddball_analysis_time

    %% Loading sensor-space data
    
    % You'll need to create 'loadExperimentInfo_ + experimentName.m file
    % that is going to contain details about your source data:
    
    % first few letters or numbers of all filenames, like nl*, BLC*, etc
    % if data exports are in subdirectory (nl*/time/RawTrials)
    % what frequencies are present in the dataset (for reverse-engineeering epoch length) 
    % see loadExperimentInfo_Lochy_Oddball.m
    
    
    experimentName = 'Lochy_Oddball';
    
    
    % load up expriment info specified in loadExperimentInfo_experimentName
    % matlab file. Lines 21-28 are generic and can be copy-pasted  
    % analysisStruct contains info about data location and data properties
    
    try
        analysisStruct = feval(['loadExperimentInfo_' experimentName]);
    catch err
        % in case unable to load the designated file, load default file
        % (not implemented atm)
        disp('Unable to load specific expriment settings, loading default');
        analysisStruct = loadExperimentInfo_Default;
    end
    
    
    % analysisStruct.domain will be propagated to rcaSetting, stats, plotting and needs to
    % be defined for the use of any high-level function 
    analysisStruct.domain = 'time';
    
    loadSettings = rcaExtra_getDataLoadingSettings(analysisStruct);
    
    % read raw data 
    [subjList, EEGData] = getRawData(loadSettings);
    
    %% RCA 
    % get generic template for RCA settings
    rcSettings = rcaExtra_getRCARunSettings(analysisStruct);
    
    %Filling out the template with subjects list:
    rcSettings.subjList = subjList;
        
    %copy settings template to 2hz analysis template 
    runSettings_c1234_2hz = rcSettings;
    % use 2Hz cycle length and duration 
    runSettings_c1234_2hz.cycleLength = rcSettings.cycleLength(1);
    runSettings_c1234_2hz.cycleDuration = rcSettings.cycleDuration(1);
    
    % the name under which RCA result will be saved inyour output/RCA directory
    
    runSettings_c1234_2hz.label = 'Conditions_1-4';
    runSettings_c1234_2hz.computeStats = 0;
    runSettings_c1234_2hz.useCnds = 1:4;

    % demonstrates that RCA result has 10Hz present in and not informative because it overpowers 2Hz response    
    rcResult_c1234 = rcaExtra_runAnalysis(runSettings_c1234_2hz, EEGData);
    
    %% Filtering out 10 Hz
    data_nF1 = rcaExtra_filterData(EEGData, analysisStruct.info.frequenciesHz, 'nF1clean', 'keep');    
    
    runSettings_c1234_2hz_nF1clean = runSettings_c1234_2hz;
    runSettings_c1234_2hz_nF1clean.label = 'Conditions_1-4_nF1_clean';
    rcResult_c1234_nF1clean = rcaExtra_runAnalysis(runSettings_c1234_2hz_nF1clean, data_nF1);

    %%  Weight Flipping (match with xDiva waveform polarity)
    
    % function will use command line prompt:
    % do you want to save the results? 
    % (Y) Do you want to save results as new matfile?
    % Vector specifies both desired order and polarity: [-1 2 3 4 5 6]
    % To change order [-2 1 3 4 5 6]
    %rcResult_all_nF1_clean = rcaExtra_adjustRCWeights(rcResult_all_nF1_clean, [-1 2 3 4 5 6]);
    
    
    %% Run RCA on individual conditions
    
%     nConditions = size(data_nF1, 2);
%     % allocate cell array to store individual condition RCA runtime settings 
%     runSettings_cnd_2hz_condition = cell(nConditions, 1);
%     
%     % allocate cell array to store individual condition RCA runtime results     
%     rcResult_condition = cell(nConditions, 1);
%     
%     % use 2Hz conditions 1-4 
%     for nc = 1:nConditions - 1
%         
%     % copy runtime settings from 2Hz nF1clean template
%         runSettings_cnd_2hz_condition{nc} = runSettings_c1234_2hz_nF1clean;
%         runSettings_cnd_2hz_condition{nc}.useCnds = nc;
%         
%         add condition-specific label
%         runSettings_cnd_2hz_condition{nc}.label = analysisStruct.info.conditionLabels{nc};
% 
%         % select subset of raw data
%         rcResult_condition{nc} = rcaExtra_runAnalysis(runSettings_cnd_2hz_condition{nc}, data_nF1);
%     end
%     

    %% Run RCA on merged conditions 
    
    % merging two conditions
    data_nF1_clean_c12 = rcaExtra_mergeDatasetConditions(data_nF1, [1, 2]);
    runSettings_2hz_c12_nF1clean = runSettings_c1234_2hz_nF1clean;
    runSettings_2hz_c12_nF1clean.label = 'Conditions_1-2_nF1_clean';
    runSettings_2hz_c12_nF1clean.useCnds = 1;
    rcResult_2hz_c12_nF1clean = rcaExtra_runAnalysis(runSettings_2hz_c12_nF1clean, data_nF1_clean_c12);
     
    %% Project through learned weights
    % projecting conditions 3, 4 through weights learned on combined [1, 2]
    
    [projected_c3_nF1_clean, projected_c4_nF1_clean] = ...
        rcaExtra_projectDataSubset(rcResult_2hz_c12_nF1clean, data_nF1(:, 3), data_nF1(:, 4));
    
    
    %% Plot
    % package with colors, make sure to have enough for each condition
    load('colorbrewer');
    % Rows = colors, columns = RGB values in 1-255 range (need to be normalized by /255) 
    colors_to_use = colorbrewer.qual.Set1{8};
        
    %% plotting all rcResult_all_nF1_clean
    % do not use stats for now
    rcResult_c1234_nF1clean.rcaSettings.computeStats = 0;

    plot_2hz_nF1clean_c14 = rcaExtra_initPlottingContainer(rcResult_c1234_nF1clean);
    plot_2hz_nF1clean_c14.conditionLabels = analysisStruct.info.conditionLabels;
    plot_2hz_nF1clean_c14.rcsToPlot = 1;
    plot_2hz_nF1clean_c14.cndsToPlot = 1:4;
    plot_2hz_nF1clean_c14.conditionColors = colors_to_use./255;
    
    % plots groups, each condition in separate window
    rcaExtra_plotWaveforms(plot_2hz_nF1clean_c14)
    
    % split data to be displayed in one figure
    [c1_rc, c2_rc, c3_rc, c4_rc]  = rcaExtra_splitPlotDataByCondition(plot_2hz_nF1clean_c14);
    rcaExtra_plotWaveforms(c1_rc, c2_rc, c3_rc, c4_rc);
    
    %% Stats
    % let's add stats computing 
    statData = rcaExtra_runStatsAnalysis(projected_c3_nF1_clean, projected_c4_nF1_clean);    
    
    % specify plotting
    plot_2hz_nF1clean_c3 = rcaExtra_initPlottingContainer(projected_c3_nF1_clean);
    plot_2hz_nF1clean_c3.conditionLabels = analysisStruct.info.conditionLabels(1);
    plot_2hz_nF1clean_c3.rcsToPlot = 1;
    plot_2hz_nF1clean_c3.cndsToPlot = 1;
    plot_2hz_nF1clean_c3.conditionColors = colors_to_use(1, :)./255;
    
    plot_2hz_nF1clean_c4 = rcaExtra_initPlottingContainer(projected_c4_nF1_clean);
    plot_2hz_nF1clean_c4.conditionLabels = analysisStruct.info.conditionLabels(2);
    plot_2hz_nF1clean_c4.rcsToPlot = 1;
    plot_2hz_nF1clean_c4.cndsToPlot = 1;
    plot_2hz_nF1clean_c4.conditionColors = colors_to_use(2, :)./255;
 
    % plot without stats
    fig_c34 = rcaExtra_plotWaveforms(plot_2hz_nF1clean_c3,plot_2hz_nF1clean_c4);
    % add stats data
    
    axes_h = get(fig_c34,'CurrentAxes');
    plot_addStatsBar_time(axes_h, statData.pValues(:, plot_2hz_nF1clean_c4.rcsToPlot), ...
        statData.sig(:, plot_2hz_nF1clean_c4.rcsToPlot), projected_c3_nF1_clean.timecourse)
    
    %% Sensor Data
    avgSensor_all = averageSensor_time(rcResult_c1234_nF1clean.rcaSettings, data_nF1);
    plot_ch_65 = rcaExtra_initPlottingContainer(avgSensor_all);
    plot_ch_65.conditionLabels = plot_2hz_nF1clean_c14.conditionLabels;
    plot_ch_65.rcsToPlot = 65;
    plot_ch_65.cndsToPlot = [1 2 3 4];
    plot_ch_65.conditionColors = colors_to_use./255;
    [c1_s, c2_s, c3_s, c4_s] = rcaExtra_splitPlotDataByCondition(plot_ch_65);
    rcaExtra_plotWaveforms(c1_s, c2_s, c3_s, c4_s);
    rcaExtra_plotWaveforms(c1_s, c1_rc);
        
end
