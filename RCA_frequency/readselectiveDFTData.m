function [subjs, sensorData, cellNoiseData1, cellNoiseData2, info] = readselectiveDFTData(subjDirPath, settings)
% Copyright 2019 Alexandra Yakovleva Stanford University
% Reads selective frequency domain data for a a project

       
     dataType = 'RLS';
     listDir = subjDirPath;
     %% list subjects
     list_subj = list_folder(fullfile(listDir, [settings.subjTag '*']));
     nsubj = numel(list_subj);
     
     %% pre-allocate
     sensorData = {};
     cellNoiseData1 = {};
     cellNoiseData2 = {};
        
    subjs = {list_subj(:).name};
    subjLoaded = ones(nsubj, 1);
    
    %% read and prep each subj  
    if (nsubj > 0)
        for s = 1:nsubj
            if (list_subj(s).isdir)
                subjDir = fullfile(subjDirPath,  list_subj(s).name);
                try
                    display(['Loading  ' list_subj(s).name]);
                    sourceDataFileName = sprintf('%s/%s %s.mat',subjDir, list_subj(s).name, dataType);
                    
                    if (~exist(sourceDataFileName, 'file'))                        
                        try
                            [signalData, indF, indB, noise1, noise2, freqLabels, binLabels, chanIncluded] = textExportToRca(subjDir, dataType);        
                        catch err
                            [signalData, indF, indB, noise1, noise2, freqLabels, binLabels, chanIncluded] = textExportToRca(subjDir, 'DFT');        
                        end
                        save(sourceDataFileName, 'signalData', 'indF','indB','noise1','noise2','freqLabels','binLabels','chanIncluded');
                    end                
                    try
                        [signalData, noise1, noise2, info] = extractDataSubset(sourceDataFileName, settings); 
                        
                        sensorData(s, :) = signalData;
                        cellNoiseData1(s, :) = noise1;
                        cellNoiseData2(s, :) = noise2;
                    catch err
                        display(['Warning, could not process data from: ' list_subj(s).name]);                      
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
end
