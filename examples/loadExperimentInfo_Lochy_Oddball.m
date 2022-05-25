function adultsLochyInfo = loadExperimentInfo_Lochy_Oddball
    
    %% info is a structure describing experiment parameters
    adultsLochyInfo = rcaExtra_genStructureTemplate;
    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    adultsLochyInfo.path.rootFolder = curr_path;
    
    % source EEG data
    srcDirPath = uigetdir(curr_path, 'Select EEG SOURCE directory');
    if (~isempty(srcDirPath))
        adultsLochyInfo.path.sourceEEGDir = srcDirPath;
    end
        
    % destination EEG directory
    adultsLochyInfo.path.destDataDir = uigetdir(curr_path, 'Select analysis results directory');
    

    %% create subdirectories
    dirNames = {'MAT', 'FIG', 'RCA'};
    dirPaths = rcaExtra_setupDestDir(adultsLochyInfo.path.destDataDir, dirNames);
    
    adultsLochyInfo.path.destDataDir_MAT = dirPaths{1};
    adultsLochyInfo.path.destDataDir_FIG = dirPaths{2};
    adultsLochyInfo.path.destDataDir_RCA = dirPaths{3};
   
    % replace default values here
    adultsLochyInfo.info.subjTag = 'nl*';
    adultsLochyInfo.info.subDirTxt = 'Exp_TEXT_HCN_128_Avg';
    adultsLochyInfo.info.subDirMat = 'Exp_MATL_HCN_128_Avg';
    adultsLochyInfo.info.groupLabels = {'Lochy Oddball'};
    adultsLochyInfo.info.conditionLabels = {'Word vs Psudofont', 'Word vs Nonword',...
        'Word vs Pseudoword', 'Word vs Psudofont jitter,', ' Word vs Psudofont evenball'};
    adultsLochyInfo.info.frequenciesHz = [2, 10];
    adultsLochyInfo.info.useSpecialDataLoader = false;
    adultsLochyInfo.info.frequencyLabels = {{'1F1' '2F1' '3F1' '4F1'}, {'1F2' '2F2'}};
    adultsLochyInfo.info.binsNmb = 10;
end



