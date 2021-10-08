function [subjs, sensorData, cellNoiseData1, cellNoiseData2, info] = readRawEEG_freq(settings)
% Copyright 2019 Alexabdra Yakovleva Stanford University
       
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
    nsubj = numel(subjs);
    
    
    %% pre-allocate
    sensorData = {};
    cellNoiseData1 = {};
    cellNoiseData2 = {};
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
                            [signalData, info.indF, info.indB, noise1, noise2, ...
                                info.freqLabels, info.binLabels, info.chanIncluded] = textExportToRca(subjSrcDir, dataType);        
                        catch err
                            rcaExtra_displayError(err);                    
                            [signalData, info.indF, info.indB, noise1, noise2, ...
                                info.freqLabels, info.binLabels, info.chanIncluded] = textExportToRca(subjSrcDir, 'DFT');        
                        end
                        save(fullfile(loadedData, processedDataFileName), 'signalData', 'noise1','noise2', 'info');
                    end                
                    try
                        [signalData, noise1, noise2, info] = extractDataSubset(fullfile(loadedData, processedDataFileName), settings); 
                        
                        sensorData(s, :) = signalData';
                        cellNoiseData1(s, :) = noise1';
                        cellNoiseData2(s, :) = noise2';
                        
                        if (isfield(settings, 'saveAsNewMatFile'))
                            sourceDataFileName_new = sprintf('%s_%s_%s.mat', subjs{s}, dataType, settings.saveAsNewMatFile);
                            save(fullfile(loadedData, sourceDataFileName_new), 'signalData', 'noise1', 'noise2', 'info');                           
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
end
