function [subjRCMean, subjSensorMean] = rcaExtra_prepareDataForStats(dataStruct, dataSettings)

% Averages and concatenates subject's RCs and Sensor data for stat analysis
% Alexandra Yakovleva, Stanford Unversity 2020

    switch dataSettings.domain
        case 'time'
            % mean RCs by subject, 
            % dims are nTimesamples x nRCs x nConditions x nSubjs
            subjRCMean = rcaExtra_prepareDataArrayForStats(dataStruct.projectedData, dataSettings);
            % repeat for mean sensor data
            subjSensorMean =rcaExtra_prepareDataArrayForStats(dataStruct.sourceData, dataSettings);
        case 'freq' 
            % for frequency, need to know nB, nF and nRCs
            % subjSensorMean: nF x nRCs x nCnd x nSubj  
            [data_Re, data_Im] = getRealImag_byBin(dataStruct.projectedData, ...
                dataSettings.nBins, dataSettings.nFreqs, dataSettings.nComp);
            [~, AvgReal, ~] = averageProject(data_Re, dataSettings.nBins);
            [~, AvgImag, ~] = averageProject(data_Im, dataSettings.nBins);    
            subjRCMean.subjAvgReal = cat(4, AvgReal{:});
            subjRCMean.subjAvgImag = cat(4, AvgImag{:});
            
            [data_Re, data_Im] = getRealImag_byBin(dataStruct.sourceData, dataSettings.nBins, dataSettings.nFreqs, 128);
            [~, AvgReal, ~] = averageProject(data_Re, dataSettings.nBins);
            [~, AvgImag, ~] = averageProject(data_Im, dataSettings.nBins);
            
            subjSensorMean.subjAvgReal = cat(4, AvgReal{:});
            subjSensorMean.subjAvgImag = cat(4, AvgImag{:});
    end
end