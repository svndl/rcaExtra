function info = loadExperimentInfo_Exports_6Hz
    
    %% info is a structure describing experiment parameters
    
    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    info.rootFolder = curr_path;
    info.srcDataDir = '';
    %% source EEG data
    srcDirPath = uigetdir(info.rootFolder, 'Select EEG SOURCE directory');
    if (~isempty(srcDirPath))
        info.sourceEEG = srcDirPath;
    end
        
    %% destination EEG directory
    info.destDataDir = curr_path;
    destDirPath = uigetdir(info.rootFolder, 'Select EEG destination directory');
    
    if (~isempty(destDirPath))
        info.destDataDir = destDirPath;
    end
    
    %% create subdirectories
    
    info.destDataDir_MAT = fullfile(info.destDataDir, 'MAT');
    if (~exist(info.destDataDir_MAT, 'dir'))
        mkdir(info.destDataDir_MAT);
    end
    
    info.destDataDir_RCA = fullfile(info.destDataDir, 'RCA');
    if (~exist(info.destDataDir_RCA, 'dir'))
        mkdir(info.destDataDir_RCA);
    end

    info.destDataDir_FIG = fullfile(info.destDataDir, 'FIG');
    if (~exist(info.destDataDir_FIG, 'dir'))
        mkdir(info.destDataDir_FIG);
    end
    
    info.subjTag = '*';
    info.subDirTxt = 'text';
    info.subDirMat = 'matlab';
    info.groupLabels = {'Adults'};
    
    info.conditionLabels = {'faces', 'cars', 'corridors', 'limbs', 'words'};
    info.frequencies = [1, 6];
    info.useSpecialDataLoader = 0;
    info.frequencyLabels = {{'1F1', '2F1', '3F1', '4F1'}, {'1F2', '2F2'}};
    info.bins = 1:10;
end



