function varargout = readRawEEG_freq_MFD(settings)
% Copyright 2019 Alexandra Yakovleva Stanford University
       
    dataType = 'RLS';
    sourceData = settings.sourceEEGDir;
    loadedData = settings.destDataDir_MAT;

    %% list subjects (unless there is a dedicated field in the settings structure)
    
    if (isfield(settings, 'useSubjectsList'))
        subjs = settings.useSubjectsList;
        isDir = ones(numel(subjs), 1);
    else
        list_subj = list_folder(fullfile(sourceData, settings.subjTag));
        subjs = {list_subj(:).name};
        isDir = [list_subj(:).isdir];
    end
    
    if (isfield(settings, 'intersectWithSubjectsList'))
        list_subj = list_folder(fullfile(sourceData, settings.subjTag));
        subjs_in_dir = {list_subj(:).name};
        isDir = [list_subj(:).isdir];        
        
        use_subjs = ismember(subjs_in_dir, settings.intersectWithSubjectsList);
        subjs = subjs_in_dir(use_subjs);
        isDir = isDir(use_subjs);        
    end
    nsubj = numel(subjs);
    
    
    %% pre-allocate
    sensorData = {};
    cellNoiseData1 = {};
    cellNoiseData2 = {};
    cellSubjErr = {};
    info = [];

    subjLoaded = ones(nsubj, 1);
    
    %% read and prep each subj  
    if (nsubj > 0)
        for s = 1:nsubj
            if (isDir(s))
                try
                    subjSrcDir = fullfile(sourceData, subjs{s}, settings.subDirTxt);
                catch err
                    subjSrcDir = fullfile(sourceData, subjs{s});
                end    
                try
                    display(['Loading  ' subjs{s}]);
                    processedDataFileName = sprintf('%s_%s.mat', subjs{s}, dataType);
                    
                    if (~exist(fullfile(loadedData, processedDataFileName), 'file'))                        
                        try
                            [signalData, noise1, noise2, subjStdErr, info] = exportFrequencyData_beta(subjSrcDir, dataType);        
                        catch err
                            rcaExtra_displayError(err);                    
                            [signalData, noise1, noise2, info] = exportFrequencyData_beta(subjSrcDir, 'DFT');        
                        end
                        save(fullfile(loadedData, processedDataFileName), 'signalData', 'noise1', 'noise2', 'subjStdErr', 'info');
                    end                
                    try
                        [signalData, noise1, noise2, subjErr, info] = extractDataSubset(fullfile(loadedData, processedDataFileName), settings); 
                        
                        sensorData(s, :) = signalData';
                        cellNoiseData1(s, :) = noise1';
                        cellNoiseData2(s, :) = noise2';
                        
                        if exist('subjStdErr', 'var')
                            cellSubjErr(s, :) = subjErr';
                        end
                        
                        if (isfield(settings, 'saveAsNewMatFile'))
                            sourceDataFileName_new = sprintf('%s_%s_%s.mat', subjs{s}, dataType, settings.saveAsNewMatFile);
                            if exist('subjStdErr', 'var')
                                save(fullfile(loadedData, sourceDataFileName_new), 'signalData', 'noise1', 'noise2', 'subjStdErr', 'info');
                            else
                                save(fullfile(loadedData, sourceDataFileName_new), 'signalData', 'noise1', 'noise2', 'info');                                
                            end
                        end 
                    catch err
                        rcaExtra_displayError(err)                        
                        display(['Warning, could not process data from: ' subjs{s}]);
                        subjLoaded(s) = 0;                       
                    end
                catch err
                    rcaExtra_displayError(err)
                    display(['Warning, could not load data from: ' subjs{s}]);
                    subjLoaded(s) = 0;
                    
                       %do nothing
                end
            end
        end
            
    end
    subjs = subjs(subjLoaded>0);
    sensorData = sensorData(subjLoaded>0, :);
    cellNoiseData1 = cellNoiseData1(subjLoaded>0, :);
    cellNoiseData2 = cellNoiseData2(subjLoaded>0, :);  
    
    if(~isempty(cellSubjErr))
        cellSubjErr = cellSubjErr(subjLoaded>0, :);  
        [varargout{1:6}] = deal(subjs, sensorData, cellNoiseData1, cellNoiseData2, cellSubjErr, info);
    else
        [varargout{1:5}] = deal(subjs, sensorData, cellNoiseData1, cellNoiseData2, info);
    end
end
