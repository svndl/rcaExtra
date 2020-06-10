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
    loadSettings.useBins = 1:10;
    loadSettings.useFrequencies = {'1F1', '2F1', '3F1', '4F1'};
    % read raw data     
    [subjList, sensorData, cellNoiseData1, cellNoiseData2, infoOut] = getRawData(loadSettings);
    rcSettings = rcaExtra_getRCARunSettings(analysisStruct);
    rcSettings.subjList = subjList;
    
    % run RCA
    rcSettings.binsToUse = loadSettings.useBins;
    rcSettings.freqsToUse = loadSettings.useFrequencies;
    rcSettings.label = 'Condition1';
    rcSettings.useCnds = 1;
    
    rcaStruct = rcaExtra_runAnalysis(rcSettings, sensorData, cellNoiseData1, cellNoiseData2);
    statSettings = rcaExtra_getStatsSettings(rcSettings);
    [subjRCMean, subjSensorMean] = rcaExtra_prepareDataForStats(rcaStruct, statSettings);
    
    statData = rcaExtra_testSignificance(subjRCMean, [], statSettings);
    % plot settings
    
    plotSettings = rcaExtra_getPlotSettings(analysisStruct);
    
    
    
end