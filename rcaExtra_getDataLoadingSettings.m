function loadSettings = rcaExtra_getDataLoadingSettings(infoStruct)

    % function will create and partially fill output structure with data
    % loading settings.
    
    % Alexandra Yakovleva, Stanford University 2020.
    
    loadSettings.domain = infoStruct.domain;
    
    switch loadSettings.domain
        case 'time'
            loadSettings.subDirMat = infoStruct.info.subDirMat;
        case 'freq'
            loadSettings.subDirTxt = infoStruct.info.subDirTxt;
            
            % leave empty, must be defined by user later
            loadSettings.useBins  = 0;
            loadSettings.useFrequencies = {};
        otherwise
    end
    % for both time and frequency domain:
    loadSettings.sourceEEGDir = infoStruct.path.sourceEEGDir;
    loadSettings.destDataDir_MAT = infoStruct.path.destDataDir_MAT;
    loadSettings.subjTag = infoStruct.info.subjTag;
    loadSettings.useSpecialDataLoader = infoStruct.info.useSpecialDataLoader;
end