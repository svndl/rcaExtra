function main_Standard_Oddball_analysis_freq

    %% define experimentInfo
    
    experimentName = 'Exports_6Hz';
    
    % load up expriment info specified in loadExperimentInfo_experimentName
    % matlab file
    
    try
        analysisStruct = feval(['loadExperimentInfo_' experimentName]);
    catch err
        % in case unable to load the designated file, load default file
        % (not implemented atm)
        disp('Unable to load specific expriment settings, loading default');
        analysisStruct = loadExperimentInfo_Default;
    end
    
    analysisStruct.domain = 'freq';
    
    %% get load settings template structure
    loadSettings = rcaExtra_getDataLoadingSettings(analysisStruct);
    
    %% fill structure with actual parameters
    loadSettings.useBins = 1:10;
    loadSettings.useFrequencies = {'1F1', '2F1', '3F1', '4F1'};
    
    %% read raw data     
    [subjList, sensorData, cellNoiseData1, cellNoiseData2, ~] = getRawData(loadSettings);
    
    %% re-bin data for condition-by-condition analysis
    
    nFreqs = length(loadSettings.useFrequencies);

    sensorData_1bin = cellfun(@(x) rcaExtra_reshapeBinsToTrials(x, nFreqs),...
        sensorData, 'UniformOutput', false);
    noise_LO_1bin = cellfun(@(x) rcaExtra_reshapeBinsToTrials(x, nFreqs),...
        cellNoiseData1, 'UniformOutput', false);
    noise_HI_1bin = cellfun(@(x) rcaExtra_reshapeBinsToTrials(x, nFreqs),...
        cellNoiseData2, 'UniformOutput', false);
    
    %% create another dataset to merge all conditions at the trial level
    sensorData_1bin_5cnd = rcaExtra_mergeDatasetConditions(sensorData_1bin);    
    noise_LO_1bin_5cnd = rcaExtra_mergeDatasetConditions(noise_LO_1bin);    
    noise_HI_1bin_5cnd = rcaExtra_mergeDatasetConditions(noise_HI_1bin);    
    
    %% create generic RC runtime settings template structure
    rcSettings = rcaExtra_getRCARunSettings(analysisStruct);
    
    %% fill the RC runtime template structure with real parameters
    
    % Define subject names. Will be used to compare between
    % saved (stored) results and requested results
    rcSettings.subjList = subjList;
   
    % Define bin vector. Will be used to compare between
    % saved (stored) results and requested results
    rcSettings.useBins = 1;
    
    % Define frequency list. Will be used to compare between
    % saved (stored) results and requested results
    rcSettings.useFrequencies = loadSettings.useFrequencies;
    
    %% run analysis on all conditions
    nConditions = size(sensorData, 2);
    rcSettings_byCondition = cell(1, nConditions);
    rcResultStruct_byCondition = cell(1, nConditions);
    
    for nc = 1:nConditions
        % create copy of rcSettings for each condition
        rcSettings_byCondition{nc} = rcSettings;
        rcSettings_byCondition{nc}.label = analysisStruct.info.conditionLabels{nc};
        rcSettings_byCondition{nc}.useCnds = nc;
        
        rcResultStruct_byCondition{nc} = rcaExtra_runAnalysis(rcSettings_byCondition{nc}, sensorData_1bin, noise_LO_1bin, noise_HI_1bin);
    end
    
    %% run analysis on pooled dataset
    rcSettings_pooled = rcSettings;
    rcSettings_pooled.label = 'pooled conditions';
    rcSettings_pooled.useCnds = 1;
    
    rcResultStruct_pooled = rcaExtra_runAnalysis(rcSettings_pooled, ...
        sensorData_1bin_5cnd, noise_LO_1bin_5cnd, noise_HI_1bin_5cnd);
    
    %% run analysis on all conditions
    
    rcSettings_all = rcSettings;
    rcSettings_all.label = 'all conditions';
    rcSettings_all.useCnds = 1:nConditions;
    
    rcResultStruct_all = rcaExtra_runAnalysis(rcSettings_all, ...
        sensorData_1bin, noise_LO_1bin, noise_HI_1bin);
    
    %% project data through pooled weights 
        
    [projected_sourceData, projectedNoise_LO, projectedNoise_HI] = ...
        projectDatasets(rcResultStruct_pooled.W, ...
        sensorData_1bin, noise_LO_1bin, noise_HI_1bin);
    
    %% copy rcResultStruct_all and replace relevant fields
    
    rcResultProjected = rcResultStruct_all;
    % replace projected data
    rcResultProjected.projectedData = projected_sourceData;
    rcResultProjected.noiseData.higherSideBand = projectedNoise_HI;
    rcResultProjected.noiseData.lowerSideBand = projectedNoise_LO;
    % copy relevant weights
    rcResultProjected.W = rcResultStruct_pooled.W;
    % re-compute averages
    rcResultProjected = rcaExtra_computeAverages(rcResultProjected);
    
    % option 2 is to use high-level projection, however,
    % projection for noise is not implemented 
    % callback would be 
    % rcresultProjected = rcaExtra_projectDataSubset(rcResultStruct_pooled,
    % sensorData_1bin);
    
    
    
    %% visualization 
    cndsToPlot = rcSettings_all.useCnds;
    rcsToPlot = 1:3;
    conditionLabels = {'C1', 'C2', 'C3', 'C4', 'C5'};
    
    load('colorbrewer');
    colorsToUse = colorbrewer.qual.Set1{5}./255;

    % init plotting containers
    plot_projected = rcaExtra_initPlottingContainer(rcResultProjected);
    plot_projected.conditionLabels = conditionLabels;
    plot_projected.rcsToPlot = rcsToPlot;
    plot_projected.cndsToPlot = cndsToPlot;
    plot_projected.conditionColors = colorsToUse;
    
    plot_all = rcaExtra_initPlottingContainer(rcResultStruct_all);
    plot_all.conditionLabels = conditionLabels;
    plot_all.rcsToPlot = rcsToPlot;
    plot_all.cndsToPlot = cndsToPlot;
    
    plot_all.conditionColors = 0.65.*colorsToUse;    
    rcaExtra_plotAmplitudeWithStats(plot_projected, plot_all, rcResultProjected, rcResultStruct_all)
   
end