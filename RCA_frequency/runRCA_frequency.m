function rcaResult = runRCA_frequency(rcaSettings, sensorData, cellNoiseData1, cellNoiseData2)
% Alexandra Yakovleva, Stanford University 2012-2020.

    fprintf('Running RCA frequency...\n');
    if (isfield(rcaSettings, 'useCnds') && ~isempty(rcaSettings.useCnds))
        dataSlice = sensorData(:, rcaSettings.useCnds);
    else
        dataSlice = sensorData;
        rcaSettings.useCnds = size(sensorData, 2);
    end
    
    savedFile = fullfile(rcaSettings.destDataDir_RCA, [rcaSettings.label, '_freq.mat']);
    if (~exist(savedFile, 'file'))
        [rcaData, W, A, Rxx, Ryy, Rxy, dGen, ~] = ...
            rcaRun(dataSlice, rcaSettings.nReg, rcaSettings.nComp); 
        covData.Rxx = Rxx;
        covData.Ryy = Ryy;
        covData.Rxy = Rxy;
        covData.sortedGeneralizedEigenValues = dGen;
        noiseData.lowerSideBand = rcaProject(cellNoiseData1, W); 
        noiseData.higherSideBand = rcaProject(cellNoiseData2, W);
        %% generate final output struct
        rcaResult.projectedData = rcaData;
        rcaResult.sourceData = dataSlice;

        rcaResult.W = W;
        rcaResult.A = A;
        rcaResult.covData = covData; 
        rcaResult.noiseData = noiseData;
        rcaResult.rcaSettings = rcaSettings;
        save(savedFile, 'rcaResult');        
    else
        try
            load(savedFile, 'rcaResult');
            % compare runtime settings
            if (~rcaExtra_compareRCASettings_freq(rcaResult.rcaSettings, rcaSettings))
                % if settings don't match, save old file and re-run the analysis
            
                disp('New settings don''t match previous instance, re-running RCA ...'); 
                matFileRCA_old = fullfile(rcaSettings.destDataDir_RCA, ['previous_rcaResults_' rcaSettings.label '_freq.mat']);
                movefile(savedFile ,matFileRCA_old, 'f');
                rcaResult = runRCA_frequency(sensorData, cellNoiseData1, cellNoiseData2, rcaSettings);
            end
        catch err
            disp('Failed to load stored data, re-running RCA ...');
            matFileRCA_old = fullfile(rcaSettings.destDataDir_RCA, ['corrupted_rcaResults_' rcaSettings.label '_freq.mat']);
            movefile(savedFile ,matFileRCA_old, 'f');
            rcaResult = runRCA_frequency(sensorData, cellNoiseData1, cellNoiseData2, rcaSettings);            
        end
    end
    
    statSettings = rcaExtra_getStatsSettings(rcSettings);
    [subjRCMean, ~] = rcaExtra_prepareDataForStats(rcaResult, statSettings);    
    % add stats    
    statData = rcaExtra_testSignificance(subjRCMean, [], statSettings);
    projAvg = averageFreqData(rcaData, numel(rcaSettings.binsToUse), ...
        numel(rcaSettings.freqsToUse));
    try
        rcPlot_freq(projAvg, freq, A, statData, Rxx, Ryy, dGen);
    catch
        
    end
end
