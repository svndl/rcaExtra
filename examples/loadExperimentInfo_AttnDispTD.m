function info = loadExperimentInfo_AttnDispTD
    
    %% info is a structure describing experiment parameters
    info = rcaExtra_genStructureTemplate;
    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    info.path.rootFolder = curr_path;
    
    % source EEG data
    srcDirPath = uigetdir(curr_path, 'Select EEG SOURCE directory');
    if (~isempty(srcDirPath))
        info.path.sourceEEGDir = srcDirPath;
    end
        
    % destination EEG directory
    info.path.destDataDir = uigetdir(curr_path, 'Select analysis results directory');
    

    %% create subdirectories
    dirNames = {'MAT', 'FIG', 'RCA'};
    dirPaths = rcaExtra_setupDestDir(info.path.destDataDir, dirNames);
    
    info.path.destDataDir_MAT = dirPaths{1};
    info.path.destDataDir_FIG = dirPaths{2};
    info.path.destDataDir_RCA = dirPaths{3};
   
    % replace default values here
    info.info.subjTag = 'nl*';
    info.info.subDirTxt = 'text';
    info.info.subDirMat = 'matlab';
    info.info.groupLabels = {'Adults 1.4 Hz'};
    info.info.conditionLabels = {'Abs attend nonius', 'Abs attend stim', 'Rel attend nonius', 'Rel attend stim'};
    info.info.frequenciesHz = [1.4286, 20];
    info.info.useSpecialDataLoader = false;
    info.info.frequencyLabels = {{'1F1' '2F1' '3F1' '4F1'}, {'1F2'}};
    info.info.binsNmb = 10;
end



