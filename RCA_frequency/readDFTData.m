function [subjs, sensorData, sensorData_avg, indF, indB, ...
    cellNoiseData1, cellNoiseData1_avg, cellNoiseData2, cellNoiseData2_avg, ...
    freqLabels, binLabels, chanIncluded] = readDFTData(varargin)

    eegSrc = varargin{1};
    
    
    dataType = 'RLS';
    fnHandle = @textExportToRca;
    listFreqs = {};
    listDir = eegSrc;    
    if (nargin > 1)
        listDir = fullfile(eegSrc, varargin{2});
    end
    if (nargin > 2)
        listFreqs = varargin{3};
        fnHandle = @export2F;
    end
    list_subj = list_folder(listDir);        
    
    %% preallocate
    nsubj = numel(list_subj);
    sensorData = {};
    cellNoiseData1 = {};
    cellNoiseData2 = {};
    
    sensorData_avg = {};
    cellNoiseData1_avg = {};
    cellNoiseData2_avg = {};

    indF = [];
    indB = [];
    freqLabels = [];
    binLabels = [];
    chanIncluded = [];
    subFreqIdx = cell(nsubj, 1);
    subBinIdx = cell(nsubj, 1);
    subFreqLabels = cell(nsubj, 1);
    subBinLabels = cell(nsubj, 1);    
    subjs = {list_subj(:).name};
    subjLoaded = ones(nsubj, 1);
    %% read and prep each subj  
    if (nsubj > 0)
        for s = 1:nsubj
            if (list_subj(s).isdir)
                subjDir = fullfile(eegSrc,  list_subj(s).name);
                try
                    display(['Loading  ' list_subj(s).name]);
                    sourceDataFileName = sprintf('%s/%s %s.mat',subjDir, list_subj(s).name, dataType);
                    
                    if (exist(sourceDataFileName, 'file'))
                        load(sourceDataFileName)
                    else 
                        try
                            [signalData, indF, indB, noise1, noise2, freqLabels, binLabels, chanIncluded] = fnHandle(subjDir, dataType, listFreqs);        
                            save(sourceDataFileName,'signalData','indF','indB','noise1','noise2','freqLabels','binLabels','chanIncluded');
                        catch err
                            [signalData, indF, indB, noise1, noise2, freqLabels, binLabels, chanIncluded] = fnHandle(subjDir, 'DFT', listFreqs);        
                            save(sourceDataFileName,'signalData','indF','indB','noise1','noise2','freqLabels','binLabels','chanIncluded');
                        end
                            
                    end
                    try
                        [signalData, noise1, noise2, subFreqIdx{s}, subBinIdx{s}, subFreqLabels{s}, subBinLabels{s}] = ...
                                selectDataForTraining(sourceDataFileName);                          
                        sensorData(s, :) = signalData;
                        cellNoiseData1(s, :) = noise1;
                        cellNoiseData2(s, :) = noise2;
                    catch err
                        display(['Warning, could not process data from: ' list_subj(s).name]);                      
                    end
                    
                    try
                        [signalData_avg, noise1_avg, noise2_avg, ~, ~, ~, ~] = selectDataForTraining(sourceDataFileName);                        
                        sensorData_avg(s, :) = signalData_avg;
                        cellNoiseData1_avg(s, :) = noise1_avg;
                        cellNoiseData2_avg(s, :) = noise2_avg;
                    catch err
                    end
                    for c = 1:size(signalData, 1)
                        freqIndices{c} = subFreqIdx{s}{c};
                        binIndices{c} = subBinIdx{s}{c};
                        freqLabels{c} = subFreqLabels{s}{c};
                        binLabels{c} = subBinLabels{s}{c};
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
