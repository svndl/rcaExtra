function template = rcaExtra_genStructureTemplate

    %% template structure is going to have 3 parts:
    
    %% Part 1, paths (dynamic parameters defined by user)
    
    % analysis script location, string
    template.path.rootFolder = '';
    % source EEG directory, user-defined, string
    template.path.sourceEEGDir = '';
    % results EEG directory, user-defined, string
    template.path.destDataDir = '';
    % subdirectories with figures, rc results and processed mat files, string 
    template.path.destDataDir_MAT = '';
    template.path.destDataDir_RCA = '';
    template.path.destDataDir_FIG = '';

    %% Part 2, experiment info (static parameters defined by researcher)
    
    % special subject tag, string (must be uniform for all subjs)
    template.info.subjTag = 'nl*';
    % subdirectories with frequency/time domain data, string, uniform for
    % all subjs
    template.info.subDirTxt = 'Exp_TEXT_HCN_128_Avg_Btn';
    template.info.subDirMat = 'Exp_MATL_HCN_128_Avg_Btn';
    
    % group labels, cell array of {groupA, groupB, .... groupZ};
    template.info.groupLabels = {''};
    
    % condition labels, cell array of {'Condition1', 'Condition2', ...,
    % 'ConditionN'};
    template.info.conditionLabels = {''};
    
    % frequencies used, double vector
    template.info.frequenciesHz = [1, 2];
    
    % special source data loading function, boolean 
    template.info.useSpecialDataLoader = false;
    
    % frequency multiples available (all), cell array of string cells for each
    % frequency, i.e. {{multiples of f1}, {multiples of f2}, etc..}
    template.info.frequenciesLabels = {{'1F1', '2F1'}};
   
    % unique bins used, integer
    template.info.binsNmb = 10;
    
    %% Part 3 will be analysis-specific and should be defined by analysis script 
end