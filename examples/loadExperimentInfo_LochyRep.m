function out = loadExperimentInfo_LochyRep
    
    %% info is a structure describing experiment parameters
    out = rcaExtra_genStructureTemplate;
    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    out.path.rootFolder = curr_path;
    
    % source EEG data
    srcDirPath = uigetdir(curr_path, 'Select EEG SOURCE directory');
    if (~isempty(srcDirPath))
        out.path.sourceEEGDir = srcDirPath;
    end
        
    % destination EEG directory
    out.path.destDataDir = uigetdir(curr_path, 'Select analysis results directory');
    

    %% create subdirectories
    dirNames = {'MAT', 'FIG', 'RCA'};
    dirPaths = rcaExtra_setupDestDir(out.path.destDataDir, dirNames);
    
    out.path.destDataDir_MAT = dirPaths{1};
    out.path.destDataDir_FIG = dirPaths{2};
    out.path.destDataDir_RCA = dirPaths{3};
   
    % replace default values here
    out.info.subjTag = 'nl*';
    out.info.subDirTxt = 'Exp_TEXT_HCN_128_Avg';
    out.info.subDirMat = 'Exp_MATL_HCN_128_Avg';
    out.info.groupLabels = {'Lochy Replication'};
    out.info.conditionLabels = {'Condition1', 'Condition2', 'Condition3', 'Condition4', 'Condition5'};
    out.info.frequenciesHz = {2, 10}; %also for cnd 5 {3, 6}
    out.info.useSpecialDataLoader = false;
    out.info.frequencyLabels = {{'1F1', '2F1', '3F1', '4F1'}};
    out.info.binsNmb = 10;
end
