function [subjRCMean, subjSensorMean] = rcaExtra_prepareDataForStats(dataStruct, dataSettings)

% Averages and concatenates subject's RCs and Sensor data for stat analysis
% Alexandra Yakovleva, Stanford Unversity 2020

    subjRCMean = rcaExtra_prepareDataArrayForStats(dataStruct.projectedData, dataSettings);
    % repeat for mean sensor data
    dataSettings_source = dataSettings;
    
    dataSettings_source.nComp = 128;
    subjSensorMean = rcaExtra_prepareDataArrayForStats(dataStruct.sourceData, dataSettings_source);
end