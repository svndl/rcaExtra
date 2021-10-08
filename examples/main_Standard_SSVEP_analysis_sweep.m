function main_Standard_SSVEP_analysis_sweep
% modified by LLV
%% define experimentInfo

experimentName = 'Exports_SynapseSplit';

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
loadSettings.useFrequencies = {'1F1', '2F1', '3F1', '4F1'};

%% load data

% read raw data
[subjList, sensorData, cellNoiseData1, cellNoiseData2, ~] = getRawData(loadSettings);
rcSettings = rcaExtra_getRCARunSettings(analysisStruct);

%% bypass data loading params for actual RC run, if desired

rcSettings.subjList = subjList;
rcSettings.useBins = loadSettings.useBins;
rcSettings.useFrequencies = loadSettings.useFrequencies;
%     nConditions = size(sensorData, 2);
nConditions = 1; % LLV: bypass for Athena dataset: sweeps only in condition 4
% rcSettings_sweep_condition4 = cell(1, nConditions);
% rcResult_condition4 = cell(1, nConditions);

rcSettings_sweep = rcSettings;


%     for nc = 1:nConditions
rcSettings_sweep_condition4 = rcSettings_sweep;
% rcSettings_sweep_condition4.useCnds = 4;
rcSettings_sweep_condition4.useCnds = [3, 4];
% add condition-specific label
% rcSettings_sweep_condition4.label = analysisStruct.info.conditionLabels{rcSettings_sweep_condition4.useCnds};
rcSettings_sweep_condition4.label = 'conds 3 and 4';


% select subset of raw data
rcResult_condition4 = rcaExtra_runAnalysis(rcSettings_sweep_condition4, sensorData, cellNoiseData1, cellNoiseData2);
% plot results
% end
end
