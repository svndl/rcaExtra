function rcaResult = runRCA_frequency(rcaSettings_current, sensorData, cellNoiseData1, cellNoiseData2)
% Alexandra Yakovleva, Stanford University 2012-2020.

    if (isfield(rcaSettings_current, 'useCnds') && ~isempty(rcaSettings_current.useCnds))
        dataSlice = sensorData(:, rcaSettings_current.useCnds)';
    else
        dataSlice = sensorData';
        rcaSettings_current.useCnds = 1:size(sensorData, 2);
    end
    fprintf('Running RCA frequency for dataset %s number of components: %d ...\n', rcaSettings_current.label, rcaSettings_current.nComp);
    % file with results
    savedFile = fullfile(rcaSettings_current.destDataDir_RCA, strcat('rcaResults_Freq_', rcaSettings_current.label, '.mat'));
     
    current_destDataDir_RCA = rcaSettings_current.destDataDir_RCA;
    
    if (~exist(savedFile, 'file'))
        [rcaData, W, A, Rxx, Ryy, Rxy, dGen, ~] = ...
            rcaRun(dataSlice, rcaSettings_current.nReg, rcaSettings_current.nComp); 
        covData.Rxx = Rxx;
        covData.Ryy = Ryy;
        covData.Rxy = Rxy;
        covData.dGen = dGen;
        try
            noiseData.lowerSideBand = rcaProject(cellNoiseData1(:, rcaSettings_current.useCnds), W); 
            noiseData.higherSideBand = rcaProject(cellNoiseData2(:, rcaSettings_current.useCnds), W);
        catch err
            % catching no noise data
            noiseData = [];
        end

        %% generate final output struct
        rcaResult.projectedData = rcaData';

        rcaResult.W = W;
        rcaResult.A = A;
        rcaResult.covData = covData; 
        rcaResult.noiseData = noiseData;
        rcaResult.rcaSettings = rcaSettings_current;
        save(savedFile, 'rcaResult');        
    else
        try
            load(savedFile, 'rcaResult');  
            % compare runtime settings
            if (~rcaExtra_compareRCASettings_freq(rcaResult.rcaSettings, rcaSettings_current))
                % if settings don't match, save old file and re-run the analysis
            
                disp('New settings don''t match previous instance, re-running RCA ...'); 
                matFileRCA_old = fullfile(current_destDataDir_RCA, ['previous_rcaResults_' rcaSettings_current.label '_freq.mat']);
                
                movefile(savedFile ,matFileRCA_old, 'f');
                rcaResult = runRCA_frequency(rcaSettings_current, dataSlice, cellNoiseData1(:, rcaSettings_current.useCnds), ...
                    cellNoiseData2(:, rcaSettings_current.useCnds));
            end
            
            % transpose and overwrite projectedData for old structures
            nSubjs = numel(rcaSettings_current.subjList);
            if (size(rcaResult.projectedData, 2) == nSubjs)
                rcaResult.projectedData = rcaResult.projectedData';
                save(savedFile, 'rcaResult');                  
            end
        catch err
            disp('Failed to load stored data, re-running RCA ...');
            rcaExtra_displayError(err);
            matFileRCA_old = fullfile(rcaSettings_current.destDataDir_RCA, ['corrupted_rcaResults_' rcaSettings_current.label '_freq.mat']);
            movefile(savedFile ,matFileRCA_old, 'f');
            rcaResult = runRCA_frequency(rcaSettings_current, dataSlice, cellNoiseData1(:, rcaSettings_current.useCnds), ...
                cellNoiseData2(:, rcaSettings_current.useCnds));            
        end
        % update the data location
        rcaResult.rcaSettings.destDataDir_RCA = current_destDataDir_RCA;
        
    end
    
    % compute average data
    %rcaResult.projectedData = rcaExtra_projectCellData(dataSlice, rcaResult.W);
    [projAvg, subjAvg, subjProj] = averageFrequencyData(rcaResult.projectedData, ...
        numel(rcaResult.rcaSettings.useBins), numel(rcaResult.rcaSettings.useFrequencies));
    rcaResult.projAvg = projAvg;
    rcaResult.subjAvg = subjAvg;
    rcaResult.subjProj = subjProj;
 
    nSubj = size(rcaResult.projectedData, 1);
    projectedDataConcat = cell(nSubj, 1);
    for s = 1:nSubj
        projectedDataConcat{s} = cat(3, rcaResult.projectedData{s, :});
    end
    
    % copy for plotting
    rcaResultPlotting = rcaResult;
    [rcaResultPlotting.projAvg, ~, ~] = averageFrequencyData(projectedDataConcat, ...
        numel(rcaResult.rcaSettings.useBins), numel(rcaResult.rcaSettings.useFrequencies));
    statSettings = rcaExtra_getStatsSettings(rcaResult.rcaSettings);
    subjRCMean = rcaExtra_prepareDataArrayForStats(projectedDataConcat, statSettings);
    
    % add stats   
    try
        statData = rcaExtra_testSignificance(subjRCMean, [], statSettings);
    catch err
        rcaExtra_displayError(err);
        statData = [];
    end
    try
        rcaExtra_plotRCSummary(rcaResultPlotting, statData);
    catch err
        rcaExtra_displayError(err);
    end
end
