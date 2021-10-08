function rcResult_condition = main_Standard_Synapse_analysis_sweep
% function [rcResult_condition, rcResult_avgs] = main_Standard_Synapse_analysis_sweep
% modified by LLV
%% define experimentInfo

experimentName = 'Exports_Synapse'; % used to call the relevant 'loadExperimentInfo_EXPNAME.m'

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

analysisStruct.domain = 'sweep';
loadSettings = rcaExtra_getDataLoadingSettings(analysisStruct);

%% put desired parameters here

loadSettings.useBins = 1:10;
% warning('DEBUGGING: using limited bins');
% loadSettings.useBins = 1:3;
loadSettings.useFrequencies = {'1F1', '2F1', '3F1', '4F1'};

%% load data

% read raw data
[subjList, sensorData, cellNoiseData1, cellNoiseData2, ~] = getRawData(loadSettings);
rcSettings = rcaExtra_getRCARunSettings(analysisStruct);

%% bypass data loading params for actual RC run, if desired

rcSettings.subjList = subjList;
rcSettings.useBins = loadSettings.useBins;
rcSettings.nBins = numel(rcSettings.useBins);
rcSettings.useFrequencies = loadSettings.useFrequencies;
rcSettings.nComp = 4; % overriding desired RC components to 4
nConditions = size(sensorData, 2);
rcSettings_sweep_condition = cell(1, nConditions);
rcResult_condition = cell(1, nConditions);
rcResult_avgs = cell(1, nConditions);

rcSettings_sweep = rcSettings;

% whether to analyze individual conditions separately, or to pool them
% together
if false
    % TESTING INDIVIDUAL CONDITIONS SEQUENTIALLY
    for condIdx = 1:nConditions
        rcSettings_sweep_condition{condIdx} = rcSettings_sweep;
        rcSettings_sweep_condition{condIdx}.useCnds = condIdx;
        % add condition-specific label
        rcSettings_sweep_condition{condIdx}.label = analysisStruct.info.conditionLabels{condIdx};
    
        % select subset of raw data
        rcResult_condition{condIdx} = rcaExtra_runAnalysis(rcSettings_sweep_condition{condIdx}, sensorData, cellNoiseData1, cellNoiseData2);
    end
else
    % TESTING MULTIPLE CONDITIONS AT ONCE
    nConditions = 2;
    rcSettings_sweep_condition = cell(1, nConditions);
    rcResult_condition = cell(1, nConditions);
    rcResult_avgs = cell(1, nConditions);
    % for condIdx = 1:nConditions
    for condIdx = 2
        rcSettings_sweep_condition{condIdx} = rcSettings_sweep;
        switch condIdx
            case 1
                rcSettings_sweep_condition{condIdx}.useCnds = [1, 2, 3];
                rcSettings_sweep_condition{condIdx}.label = 'cond 1, 2, 3';%analysisStruct.info.conditionLabels{condIdx};
                
            case 2
                rcSettings_sweep_condition{condIdx}.useCnds = 4;
                rcSettings_sweep_condition{condIdx}.label = 'cond 4';%analysisStruct.info.conditionLabels{condIdx};
        end
        % select subset of raw data
        rcResult_condition{condIdx} = rcaExtra_runAnalysis(rcSettings_sweep_condition{condIdx}, sensorData, cellNoiseData1, cellNoiseData2);
    end
end
% LLV: average sweeps together
% rcResult_avgs = cellfun(@(x) rcaExtra_computeSweepAverages(x), rcResult_condition);
% plot results
% LLV: beta sweep amplitude and phase plots plus topos for all conds
% rcaExtra_plotSweepProjAmplitudesSummary_beta(rcResult_avgs(condIdx));

end
