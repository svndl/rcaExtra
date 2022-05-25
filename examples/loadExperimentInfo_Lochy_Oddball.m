function adultsLochyzInfo = loadExperimentInfo_Lochy_Oddball
    
    %% info is a structure describing experiment parameters
    adultsLochyzInfo = rcaExtra_genStructureTemplate;
    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    adultsLochyzInfo.path.rootFolder = curr_path;
    
    % source EEG data
    srcDirPath = uigetdir(curr_path, 'Select EEG SOURCE directory');
    if (~isempty(srcDirPath))
        adultsLochyzInfo.path.sourceEEGDir = srcDirPath;
    end
        
    % destination EEG directory
    adultsLochyzInfo.path.destDataDir = uigetdir(curr_path, 'Select analysis results directory');
    

    %% create subdirectories
    dirNames = {'MAT', 'FIG', 'RCA'};
    dirPaths = rcaExtra_setupDestDir(adultsLochyzInfo.path.destDataDir, dirNames);
    
    adultsLochyzInfo.path.destDataDir_MAT = dirPaths{1};
    adultsLochyzInfo.path.destDataDir_FIG = dirPaths{2};
    adultsLochyzInfo.path.destDataDir_RCA = dirPaths{3};
   
    % replace default values here
    adultsLochyzInfo.info.subjTag = 'nl*';
    adultsLochyzInfo.info.subDirTxt = 'Exp_TEXT_HCN_128_Avg';
    adultsLochyzInfo.info.subDirMat = 'Exp_MATL_HCN_128_Avg';
    adultsLochyzInfo.info.groupLabels = {'Lochy Oddball'};
    adultsLochyzInfo.info.conditionLabels = {'Word vs Psudofont', 'Word vs Nonword',...
        'Word vs Pseudoword', 'Word vs Psudofont jitter,', ' Word vs Psudofont evenball'};
    adultsLochyzInfo.info.frequenciesHz = [2, 10];
    adultsLochyzInfo.info.useSpecialDataLoader = false;
    adultsLochyzInfo.info.frequencyLabels = {{'1F1' '2F1' '3F1' '4F1'}, {'1F2' '2F2'}};
    adultsLochyzInfo.info.binsNmb = 10;
end



