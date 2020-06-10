function runSettings = rcaExtra_getRCARunSettings(infoStruct)
% Function generates template structure for running RCA analysis

% Alexandra Yakovleva, Stanford University 2020
    runSettings.domain = infoStruct.domain;
    switch infoStruct.domain
        case 'time'
            DAQSR = 420; % data sampling rate
            runSettings.samplingRate = round(DAQSR./infoStruct.info.frequenciesHz);
            runSettings.timecourseLen = 1000./infoStruct.info.frequenciesHz;
        case 'freq'
            runSettings.freqIndices = []; % available frequencies
            runSettings.binIndices = []; % available bins
            runSettings.freqLabels = {}; % labels for frequencies
            runSettings.binLevels = {}; % labels for bins
            runSettings.binsToUse = 0; % bins used for training, vector
            runSettings.freqsToUse = 0; % frequencies used for trainig, vector 
            runSettings.trialsToUse = []; % use all trials
            runSettings.dataType = 'RLS';
        otherwise
    end
    % common variavles
    runSettings.freqsUsed = infoStruct.info.frequenciesHz;            
    runSettings.subjList = {}; % store subjects
    runSettings.nReg = 7; 
    runSettings.nComp = 6;
    runSettings.label = {};
    runSettings.useCnds = [];
    runSettings.rcPlotStyle =  'matchMaxSignsToRc1'; 
    runDate = datestr(clock,26); 
    runDate(strfind(runDate,'/')) ='';
    runSettings.runDate = runDate; % runtime info
    runSettings.destDataDir_RCA = infoStruct.path.destDataDir_RCA;
    runSettings.destDataDir_FIG = infoStruct.path.destDataDir_FIG;
end