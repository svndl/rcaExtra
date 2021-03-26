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
    
    rcResult_all = rcaExtra_runAnalysis(runSettings_1hz, EEGData);
    
    plotSettings_all = rcaExtra_getPlotSettings(rcResult_all);
    plotSettings_all.RCsToPlot = 1:3;
    
    % plotting all conditions:
    rcaExtra_plotCompareConditions_time(plotSettings_all, rcResult_all)    
    
    % comparing two conditions 
%     statSettings = rcaExtra_getStatsSettings(rcSettings);
%     rcaExtra_plotCompareGroups_time(rcResult_condition{1}, rcResult_condition{2})
end
