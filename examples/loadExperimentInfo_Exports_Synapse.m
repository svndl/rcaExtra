function synapseSplitInfo = loadExperimentInfo_Exports_Synapse
    
    %% info is a structure describing experiment parameters
    synapseSplitInfo = rcaExtra_genStructureTemplate;
    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    synapseSplitInfo.path.rootFolder = curr_path;
    
    % source EEG data
    srcDirPath = uigetdir(curr_path, 'Select EEG SOURCE directory');
    if (~isempty(srcDirPath))
        synapseSplitInfo.path.sourceEEGDir = srcDirPath;
    end
        
    % destination EEG directory
    synapseSplitInfo.path.destDataDir = uigetdir(curr_path, 'Select analysis results directory');
    

    %% create subdirectories
    dirNames = {'MAT', 'FIG', 'RCA'};
    dirPaths = rcaExtra_setupDestDir(synapseSplitInfo.path.destDataDir, dirNames);
    
    synapseSplitInfo.path.destDataDir_MAT = dirPaths{1};
    synapseSplitInfo.path.destDataDir_FIG = dirPaths{2};
    synapseSplitInfo.path.destDataDir_RCA = dirPaths{3};
   
    % replace default values here
    synapseSplitInfo.info.subjTag = '*';
    synapseSplitInfo.info.subDirTxt = 'Exp_TEXT_HCN_128_Avg';
%     synapseSplitInfo.info.subDirTxt = 'text';
    synapseSplitInfo.info.subDirMat = 'Exp_MATL_HCN_128_Avg';
    synapseSplitInfo.info.groupLabels = {'Synapse MS split'};
    synapseSplitInfo.info.conditionLabels = {'Condition 1', 'Condition 2', 'Condition 3', 'Acuity sweeps'};
    synapseSplitInfo.info.frequenciesHz = [1];
    synapseSplitInfo.info.useSpecialDataLoader = false;
    synapseSplitInfo.info.frequencyLabels = {{'1F1', '2F1', '3F1', '4F1', ...
        '5F1', '6F1', '7F1', '8F1', '9F1'}};
    synapseSplitInfo.info.binsNmb = 10;
end



