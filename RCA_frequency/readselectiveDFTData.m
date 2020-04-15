function [subjs, sensorData, cellNoiseData1, cellNoiseData2, info] = readselectiveDFTData(path_info, settings)
% Copyright 2019 Alexabdra Yakovleva Stanford University
       
    dataType = 'RLS';
    sourceData = path_info.sourceEEG;
    loadedData = path_info.destDataDir_MAT;

    %% list subjects
    list_subj = list_folder(fullfile(sourceData, settings.subjTag));
    nsubj = numel(list_subj);
    
    
    %% pre-allocate
    sensorData = {};
    cellNoiseData1 = {};
    cellNoiseData2 = {};
    info = [];

    subjs = {list_subj(:).name};
    subjLoaded = ones(nsubj, 1);
    
    %% read and prep each subj  
    if (nsubj > 0)
        for s = 1:nsubj
            if (list_subj(s).isdir)
                try
                    subjSrcDir = fullfile(sourceData, list_subj(s).name, path_info.subDirTxt);
                catch err
                    subjSrcDir = fullfile(sourceData, list_subj(s).name);
                end    
                try
                    display(['Loading  ' list_subj(s).name]);
                    processedDataFileName = sprintf('%s_%s.mat', list_subj(s).name, dataType);
                    
                    if (~exist(fullfile(loadedData, processedDataFileName), 'file'))                        
                        try
                            [signalData, info.indF, info.indB, noise1, noise2, ...
                                info.freqLabels, info.binLabels, info.chanIncluded] = textExportToRca(subjSrcDir, dataType);        
                        catch err
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
                            sourceDataFileName_new = sprintf('%s_%s_%s.mat', list_subj(s).name, dataType, settings.saveAsNewMatFile);
                            save(fullfile(loadedData, sourceDataFileName_new), 'signalData', 'noise1', 'noise2', 'info');                           
                        end 
                    catch err
                        display(['Warning, could not process data from: ' list_subj(s).name]);
                        subjLoaded(s) = 0;                       
                    end
                catch err
                    display(['Warning, could not load data from: ' list_subj(s).name]);
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
