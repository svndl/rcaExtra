function rcaStrct = rcaRun_frequency(sensorData, cellNoiseData1, cellNoiseData2, ...
    rcaSettings)
% Alexandra Yakovleva, Stanford University 2012-2020.

    fprintf('Running RCA...\n');
    if (~exist(rcaSettings.savedFile, 'file'))
        [rcaData, W, A, Rxx, Ryy, Rxy, dGen, ~] = ...
            rcaRun(sensorData, rcaSettings.nReg, rcaSettings.nComp, rcaSettings.condsToUse, [], 1, rcaSettings.rcPlotStyle); 
        covData.Rxx = Rxx;
        covData.Ryy = Ryy;
        covData.Rxy = Rxy;
        covData.sortedGeneralizedEigenValues = dGen;
        noiseData.lowerSideBand = rcaProject(cellNoiseData1, W); 
        noiseData.higherSideBand = rcaProject(cellNoiseData2, W);
        nChannels = 128;
        if rcaSettings.computeComparison
            wComparison = zeros(nChannels,1); wComparison(rcaSettings.chanToCompare) = 1;
            comparisonData = rcaProject(sensorData, wComparison);
            comparisonNoiseData.lowerSideBand = rcaProject(cellNoiseData1 ,wComparison);
            comparisonNoiseData.higherSideBand = rcaProject(cellNoiseData2, wComparison);
            rcaStrct.inputData = sensorData;
            rcaStrct.settings = rcaSettings;      
        end
        %% generate final output struct
        rcaStrct.data = rcaData;
        rcaStrct.W = W;
        rcaStrct.A = A;
        rcaStrct.covData = covData; 
        rcaStrct.noiseData = noiseData;
        save(rcaSettings.savedFile, 'rcaStrct');
        
        %% create a "component" of just one channel for performance evaluation if requested
    else
        load(rcaSettings.savedFile);
    end
end
