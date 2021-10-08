function rcResultStruct_byCondition = main_Standard_OnOff_Students_analysis_freq

    %% define experimentInfo
    
    experimentName = 'OnOff_Students';
    
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
%     loadSettings.useBins = 1:10;
    loadSettings.useBins = 1;
    loadSettings.useFrequencies = {'1F1', '2F1', '3F1', '4F1'};
    
    %% read raw data     
    [subjList, sensorData, cellNoiseData1, cellNoiseData2, ~] = getRawData(loadSettings);
    
    %% get the RC runtime settings template structure
    rcSettings = rcaExtra_getRCARunSettings(analysisStruct);
    
    %% fill the RC runtime template structure with real parameters
    
    % Define subject names. Will be used to compare between
    % saved (stored) results and requested results
    rcSettings.subjList = subjList;
   
    % Define bin vector. Will be used to compare between
    % saved (stored) results and requested results
    rcSettings.useBins = loadSettings.useBins;
    
    % Define frequency list. Will be used to compare between
    % saved (stored) results and requested results
    rcSettings.useFrequencies = loadSettings.useFrequencies;
    
    
    % run analysis on all conditions
    %
%     nConditions = size(sensorData, 2);
%     rcSettings_byCondition = cell(1, nConditions);
%     rcResultStruct_byCondition = cell(1, nConditions);
%     for nc = 1:nConditions
%         rcSettings_byCondition{nc} = rcSettings;
%         rcSettings_byCondition{nc}.label = analysisStruct.info.conditionLabels{nc};
%         rcSettings_byCondition{nc}.useCnds = nc;
%         
%         rcResultStruct_byCondition{nc} = rcaExtra_runAnalysis(rcSettings_byCondition{nc}, sensorData, cellNoiseData1, cellNoiseData2);
%     end
    %
    % trying to run two "superconditions": 1 (conds 1 and 2) and 2 (conds 3
    % and 4)
    % run analysis on all conditions
    
    nConditions = 2;
    rcSettings_byCondition = cell(1, nConditions);
    rcResultStruct_byCondition = cell(1, nConditions);
    for nc = 1:nConditions
        rcSettings_byCondition{nc} = rcSettings;
        rcSettings_byCondition{nc}.label = analysisStruct.info.conditionLabels{nc};
        switch nc
            case 1
                rcSettings_byCondition{nc}.useCnds = [1, 2];
            case 2
                rcSettings_byCondition{nc}.useCnds = [3, 4]; 
        end
        rcResultStruct_byCondition{nc} = rcaExtra_runAnalysis(rcSettings_byCondition{nc}, sensorData, cellNoiseData1, cellNoiseData2);
        
    end
    
end