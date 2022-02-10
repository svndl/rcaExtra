function sensorResultTemplate = rcaExtra_createSensorSpaceStruct(rcaResultTemplate, SensorData, Noise1, Noise2)
    sensorResultTemplate = rcaResultTemplate;
    sensorResultTemplate.projectedData = SensorData;
    sensorResultTemplate.noiseData.lowerSideBand = Noise1;
    sensorResultTemplate.noiseData.higherSideBand = Noise2;
    
    nComps = size(SensorData{1, 1}, 2);
    
    sensorResultTemplate.W = diag(ones(1, nComps));    
    sensorResultTemplate.rcaSettings.nComp = nComps;
    sensorResultTemplate.rcaSettings.label = rcaResultTemplate.rcaSettings.label;
    sensorResultTemplate = rcaExtra_computeAverages(sensorResultTemplate);
end