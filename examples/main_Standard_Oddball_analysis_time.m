function main_Standard_Oddball_analysis_time

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
    
    runSettings_1hz = rcSettings;
    runSettings_1hz.samplingRate = rcSettings.samplingRate(1);
    runSettings_1hz.timecourseLen = rcSettings.timecourseLen(1);
    
    
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
    runSettings_1hz.label = 'AllConditions';
    
    % demonstrate that RCA result has 6Hz present in and not informative
    runSettings_1hz.computeStats = 0;
    rcResult_all = rcaExtra_runAnalysis(runSettings_1hz, EEGData);
    
    % filter out 6Hz
    data_nF1 = rcaExtra_filterData(EEGData, analysisStruct.info.frequenciesHz, 'nF1clean', 'keep');
    
    runSettings_1hz_clean = runSettings_1hz;
    runSettings_1hz_clean.label = 'AllConditions_nF1_clean';

    rcResult_all_nF1_clean = rcaExtra_runAnalysis(runSettings_1hz_clean, data_nF1);
    
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
    plot_1hz_all.cndsToPlot = [1:numel(analysisStruct.info.conditionLabels)];
    plot_1hz_all.conditionColors = colors_to_use./255;
    % plots groups, each condition in separate window
    rcaExtra_plotWaveforms(plot_1hz_all)
    
    %split data to be displayed in one figure
    [c1, c2, c3, c4, c5]  = rcaExtra_splitPlotDataByCondition(plot_1hz_all);
    rcaExtra_plotWaveforms(c1, c2, c3, c4, c5)
        
end
