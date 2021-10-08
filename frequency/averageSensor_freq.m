function sensorResult = averageSensor_freq(currSettings, dataIn)
    % compute average data
    [projAvg, subjAvg, subjProjected] = averageFrequencyData(dataIn, ...
        numel(currSettings.useBins), numel(currSettings.useFrequencies));
    sensorResult.projAvg = projAvg;
    sensorResult.subjAvg = subjAvg;
    sensorResult.subjProj = subjProjected;
    sensorResult.projectedData = dataIn;
    % add noise averaging, old structures might not have the field
%     if (isfield(dataIn, 'noiseData'))
%         try
%             [noiseLowAvg, ~, ~] = averageFrequencyData(rcaResult.noiseData.lowerSideBand, ...
%                 numel(rcaResult.rcaSettings.useBins), numel(rcaResult.rcaSettings.useFrequencies));
%         
%             [noiseHighAvg, ~, ~] = averageFrequencyData(rcaResult.noiseData.higherSideBand, ...
%                 numel(rcaResult.rcaSettings.useBins), numel(rcaResult.rcaSettings.useFrequencies));
%     	catch err
%             rcaExtra_displayError(err);
%             noiseLowAvg = projAvg;
%             noiseHighAvg = projAvg;
%         end
%         sensorResult.noiseLowAvg = noiseLowAvg;
%         sensorResult.noiseHighAvg = noiseHighAvg;
%     end
    sensorResult.rcaSettings = currSettings;
end
