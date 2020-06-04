function [subjRCMean, subjSensorMean] = rcaExtra_prepareDataForStats(dataStruct, settings)

% Averages and concatenates subject's RCs and Sensor data for stat analysis
% Alexandra Yakovleva, Stanford Unversity 2020

    switch settings.domain
        case 'time'
            % mean RCs by subject, 
            % dims are nTimesamples x nRCs x nConditions x nSubjs
            subjRCMeanCell = cellfun(@(x) nanmean(x, 3), dataStruct.projectedData, 'uni', false);
            subjRCMean = cat(4, subjRCMeanCell{:});
            [nSubj, nCnd] = size(subjRCMeanCell);
            [nSamples, nRcs, ~, ~] = size(subjRCMean);
            % reshape and permute to preserve number of conditions
            subjRCMean = reshape(subjRCMean, [nSamples nRcs nSubj nCnd]);
            subjRCMean = permute(subjRCMean, [1 2 4 3]);

            % repeat for mean sensor data
            subjSensorMeanCell = cellfun(@(x) nanmean(x, 3), dataStruct.sourceData, 'uni', false);
            subjSensorMean = cat(4, subjSensorMeanCell{:});
            subjSensorMean = reshape(subjSensorMean, [nSamples 128 nSubj nCnd]);
            subjSensorMean = permute(subjSensorMean, [1 2 4 3]);
                       
        case 'freq' 
            % for frequency, need to know nB, nF and nRCs
            % subjSensorMean: nF x nRCs x nCnd x nSubj  
            [data_Re, data_Im] = getRealImag_byBin(dataStruct.projectedData, ...
                settings.nBins, settings.nFreqs, settings.nComponents);
            [~, subjRCMean.subjAvgReal, ~] = averageProject(data_Re, settings.nBins);
            [~, subjRCMean.subjAvgImag, ~] = averageProject(data_Im, settings.nBins);    

            [data_Re, data_Im] = getRealImag_byBin(dataStruct.sourceData, settings.nBins, settings.nFreqs, 128);
            [~, subjSensorMean.subjAvgReal, ~] = averageProject(data_Re, settings.nBins);
            [~, subjSensorMean.subjAvgImag, ~] = averageProject(data_Im, settings.nBins);    
    end
end