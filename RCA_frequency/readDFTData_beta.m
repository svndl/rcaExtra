function varargout = readDFTData_beta(varargin)
% Alexandra Yakovleva, Stanford University 2012-2020.

    eegSrcDir = varargin{1}.srcEEG;
    eegMatDir = varargin{1}.loadedEEG;
    dataType = 'RLS';
    eegDir = eegSrcDir;
    if (nargin > 1) 
        eegDir = fullfile(eegSrcDir, varargin{2});
    end

    list_subj = list_folder(eegDir);        
    
    %% preallocate
    nsubj = numel(list_subj);
    sensorData = {};
    cellNoiseData1 = {};
    cellNoiseData2 = {};
    
%     sensorData_avg = {};
%     cellNoiseData1_avg = {};
%     cellNoiseData2_avg = {};

    indF = [];
    indB = [];
    freqLabels = [];
    binLabels = [];
    chanIncluded = [];
%     subFreqIdx = cell(nsubj, 1);
%     subBinIdx = cell(nsubj, 1);
%     subFreqLabels = cell(nsubj, 1);
%     subBinLabels = cell(nsubj, 1);    
    subjs = {list_subj(:).name};
    subjLoaded = ones(nsubj, 1);
    %% read and prep each subj  
    if (nsubj > 0)
        for s = 1:nsubj
            if (list_subj(s).isdir)
                subjSrcDir = fullfile(eegSrcDir,  list_subj(s).name);
                subjMatDir = fullfile(eegMatDir,  list_subj(s).name);
                
                try
                    display(['Loading  ' list_subj(s).name]);
                    sourceDataFileName = sprintf('%s_%s.mat', subjMatDir, dataType);
                    
                    if (exist(sourceDataFileName, 'file'))
                        load(sourceDataFileName)
                    else 
                        [signalData, noise1, noise2, freqLabels, binLabels] = exportFrequencyData(subjSrcDir);        
                        save(sourceDataFileName, 'signalData',  'noise1', 'noise2', 'freqLabels', 'binLabels');                                             
                    end
                    sensorData(s, :) = signalData';
                    cellNoiseData1(s, :) = noise1';
                    cellNoiseData2(s, :) = noise2';
                    clear signalData; clear noise1; clear noise2;
%                     try
%                         [signalData, noise1, noise2, ~, ~, ~, ~] = ...
%                                 selectDataForTraining(sourceDataFileName);                          
%                         sensorData(s, :) = signalData';
%                         cellNoiseData1(s, :) = noise1';
%                         cellNoiseData2(s, :) = noise2';
%                     catch err
%                         display(['Warning, could not process data from: ' list_subj(s).name]);                      
%                     end
                    
%                     try
%                         [signalData_avg, noise1_avg, noise2_avg, ~, ~, ~, ~] = selectDataForTraining(sourceDataFileName);                        
%                         sensorData_avg(s, :) = signalData_avg;
%                         cellNoiseData1_avg(s, :) = noise1_avg;
%                         cellNoiseData2_avg(s, :) = noise2_avg;
%                     catch err
%                     end
%                     for c = 1:size(signalData, 1)
%                         freqLabels{c} = subFreqLabels{s}{c};
%                         binLabels{c} = subBinLabels{s}{c};
%                     end  
                catch err
                    display(['Warning, could not load data from: ' list_subj(s).name]);
                    display(['Checking sourceData.mat for ' list_subj(s).name]);
                    sourceDataFileName_generic = fullfile(subjSrcDir, 'sourceData.mat');
                    load(sourceDataFileName_generic);
                    
                    
                    subjLoaded(s) = 0;
                       %do nothing
                end
            end
        end
    end
    subjs = subjs(subjLoaded>0);
    varargout{1} = sensorData;
    varargout{2} = cellNoiseData1;
    varargout{3} = cellNoiseData2;
    varargout{4} = freqLabels;
    varargout{5} = binLabels;
    varargout{6} = subjs;
end
