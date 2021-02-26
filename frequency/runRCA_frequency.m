function rcaResult = runRCA_frequency(rcaSettings, sensorData, cellNoiseData1, cellNoiseData2)
% Alexandra Yakovleva, Stanford University 2012-2020.

    if (isfield(rcaSettings, 'useCnds') && ~isempty(rcaSettings.useCnds))
        dataSlice = sensorData(:, rcaSettings.useCnds)';
    else
        dataSlice = sensorData';
        rcaSettings.useCnds = 1:size(sensorData, 2);
    end
    fprintf('Running RCA frequency for dataset %s number of components: %d ...\n', rcaSettings.label, rcaSettings.nComp);
    % file with results
    savedFile = fullfile(rcaSettings.destDataDir_RCA, strcat('rcaResults_Freq_', rcaSettings.label, '.mat'));
     
    if (~exist(savedFile, 'file'))
        [rcaData, W, A, Rxx, Ryy, Rxy, dGen, ~] = ...
            rcaRun(dataSlice, rcaSettings.nReg, rcaSettings.nComp); 
        covData.Rxx = Rxx;
        covData.Ryy = Ryy;
        covData.Rxy = Rxy;
        covData.dGen = dGen;
        noiseData.lowerSideBand = rcaProject(cellNoiseData1(:, rcaSettings.useCnds), W); 
        noiseData.higherSideBand = rcaProject(cellNoiseData2(:, rcaSettings.useCnds), W);
        
        %% generate final output struct
        rcaResult.projectedData = rcaData';

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
                rcaResult = runRCA_frequency(rcaSettings, sensorData, cellNoiseData1, cellNoiseData2);
            end
            
            % transpose and overwrite projectedData for old structures
            nSubjs = numel(rcaSettings.subjList);
            if (size(rcaResult.projectedData, 2) == nSubjs)
                rcaResult.projectedData = rcaResult.projectedData';
                save(savedFile, 'rcaResult');                  
            end
        catch err
            disp('Failed to load stored data, re-running RCA ...');
            rcaExtra_displayError(err);
            matFileRCA_old = fullfile(rcaSettings.destDataDir_RCA, ['corrupted_rcaResults_' rcaSettings.label '_freq.mat']);
            movefile(savedFile ,matFileRCA_old, 'f');
            rcaResult = runRCA_frequency(rcaSettings, sensorData, cellNoiseData1, cellNoiseData2);            
        end
    end
    
    % compute average data
    [projAvg, subjAvg, subjProj] = averageFrequencyData(rcaResult.projectedData, ...
        numel(rcaSettings.useBins), numel(rcaSettings.useFrequencies));
    rcaResult.projAvg = projAvg;
    rcaResult.subjAvg = subjAvg;
    rcaResult.subjProj = subjProj;
 
    statSettings = rcaExtra_getStatsSettings(rcaSettings);
    subjRCMean = rcaExtra_prepareDataArrayForStats(rcaResult.projectedData, statSettings);
    
    % add stats   
    try
        statData = rcaExtra_testSignificance(subjRCMean, [], statSettings);
    catch err
        rcaExtra_displayError(err);
        statData = [];
    end
    try
        rcaExtra_plotRCSummary(rcaResult, statData);
    catch err
        rcaExtra_displayError(err);
    end
end
