function runSettings = rcaExtra_getRCARunSettings(infoStruct)
% Function generates template structure for running RCA analysis by copying
% neccessary fields from infoStruct and creating default/blank fields to be filled later by user.
 
% Alexandra Yakovleva, Stanford University 2020
    runSettings.domain = infoStruct.domain;
    
    switch infoStruct.domain
        case 'time'
            DAQSR = 420; % data acquisition sampling rate
            runSettings.cycleDuration = 1000./infoStruct.info.frequenciesHz; % Duration of a frequency cycle, ms 
            
            % parameters that will be checked when loading RC result:
            runSettings.cycleLength = round(DAQSR./infoStruct.info.frequenciesHz); % Number of datasamples for one frequency cycle
            
        case 'freq'            
            runSettings.dataType = 'RLS';
            
            % parameters that will be checked when loading RC result:
            runSettings.useFrequencies = {}; % frequency labels, str list
            runSettings.useBins = 0; % bins used for training, vector
        otherwise
    end
    % common variables
    runSettings.useFrequenciesHz = infoStruct.info.frequenciesHz(1); % default frequency used  
    runSettings.computeStats = 1;
    % begin parameters that will be checked when loading RC result:
    runSettings.subjList = {}; % List of subjects
    runSettings.nReg = 7; % number of regularizarion params
    runSettings.nComp = 6; % number of RC components
    runSettings.label = {}; % Dataset/ run label, will be used as a part of filename  
    runSettings.useCnds = []; % Number of conditions to use from data. If empty, all conditions will be used.
    % end parameters that will be checked when loading RC result:
    
    runSettings.rcPlotStyle =  'matchMaxSignsToRc1'; 
    runDate = datestr(clock,26); 
    runDate(strfind(runDate,'/')) ='';
    runSettings.runDate = runDate; % runtime info
    runSettings.destDataDir_RCA = infoStruct.path.destDataDir_RCA; % where to save RC results matfile 
    runSettings.destDataDir_FIG = infoStruct.path.destDataDir_FIG; % where to save RC figures
end