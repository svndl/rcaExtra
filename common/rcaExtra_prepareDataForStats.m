function subjRCMean = rcaExtra_prepareDataForStats(rcaResult)

% Averages and concatenates subject's RCs and Sensor data for stat analysis
% Alexandra Yakovleva, Stanford Unversity 2020

    % copy RC Settings 
    dataSettings = rcaResult.rcaSettings;
    subjRCMean = rcaExtra_prepareDataArrayForStats(rcaResult.projectedData, dataSettings);

%% N/A for source data at the moment  
%     % copy rcaSettings and replace # of Rcs with # of electrodes for mean sensor data
%     dataSettings_source = dataSettings;
%     
%     dataSettings_source.nComp = 128;
%     subjSensorMean = rcaExtra_prepareDataArrayForStats(rcaResult.sourceData, dataSettings_source);
end