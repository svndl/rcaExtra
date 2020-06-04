function edNeuro_K2 = loadExperimentInfo_EdNeuro_K2
    
    %% info is a structure describing experiment parameters
    edNeuro_K2 = rcaExtra_genStructureTemplate;
    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    edNeuro_K2.path.rootFolder = curr_path;
    
    % source EEG data
    srcDirPath = uigetdir(curr_path, 'Select EEG SOURCE directory');
    if (~isempty(srcDirPath))
        edNeuro_K2.path.sourceEEGDir = srcDirPath;
    end
        
    % destination EEG directory
    edNeuro_K2.path.destDataDir = uigetdir(curr_path, 'Select analysis results directory');
    

    %% create subdirectories
    dirNames = {'MAT', 'FIG', 'RCA'};
    dirPaths = rcaExtra_setupDestDir(edNeuro_K2.path.destDataDir, dirNames);
    
    edNeuro_K2.path.destDataDir_MAT = dirPaths{1};
    edNeuro_K2.path.destDataDir_FIG = dirPaths{2};
    edNeuro_K2.path.destDataDir_RCA = dirPaths{3};
   
    % replace default values here
    edNeuro_K2.info.subjTag = 'BLC_2*';
    edNeuro_K2.info.subDirTxt = 'Exp_TEXT_HCN_128_Avg_Btn';
    edNeuro_K2.info.subDirMat = 'Exp_MATL_HCN_128_Avg_Btn';
    edNeuro_K2.info.groupLabels = {'K2'};
    edNeuro_K2.info.conditionLabels = {'Word vs Pseudofont', 'Word vs Orthographic legal nonwords', ...
        'Orthographic legal nonwords vs Orthographic illegal nonwords', 'mindful minutes'};
    edNeuro_K2.info.frequenciesHZ = [1, 2];
    edNeuro_K2.info.useSpecialDataLoader = false;
    edNeuro_K2.info.frequencyLabels = {{'1F1', '2F1', '3F1', '4F1', '5F1', '6F1', '7F1', '8F1', '9F1'}, {'1F2', '2F2'}};
    edNeuro_K2.info.binsNmb = 10;
end



