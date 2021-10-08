function synapseSplitInfo = loadExperimentInfo_Exports_AttnMonocBinoc
    
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
    synapseSplitInfo.info.subDirTxt = 'text';
    synapseSplitInfo.info.subDirMat = 'Exp_MATL_HCN_128_Avg';
    synapseSplitInfo.info.groupLabels = {'Attn_MonocBinoc'};
    synapseSplitInfo.info.conditionLabels = {'Condition 1 attn', 'Condition 2 attn', 'Condition 3 mon bin', 'Condition 4 mon bin'};
    synapseSplitInfo.info.frequenciesHz = [2]; % , 4, 6, 8]; % TODO ask Alexandra if needs to only specify fundamental freq, in this case only one (2Hz as per RLS file)
    synapseSplitInfo.info.useSpecialDataLoader = false;
    synapseSplitInfo.info.frequencyLabels = {{'1F1', '2F1', '3F1', '4F1'}};
    synapseSplitInfo.info.binsNmb = 10;
end



