function rcaExtra_analyzeFrequencyDataset(varargin)

    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    pathToFolder = varargin;
    if(isempty(pathToFolder))
        pathToFolder = uigetdir(curr_path, 'Select MAT data source results directory');        
    end
    
    sourceData = pathToFolder;

    %% list subjects
    
    list_subj = list_folder(fullfile(sourceData, '*.mat'));

    subjs = {list_subj(:).name};
    nsubj = numel(subjs);
    datasetBinLabels = {};
    datasetFrequencyLabels = {}; 
    
    if (nsubj > 0)
        for s = 1:nsubj
            try
                display(['Loading  ' subjs{s}]);
                load(fullfile(sourceData, subjs{s}));
                % add info into datsert table
                datasetBinLabels(s, :) = info.binLabels';
                datasetFrequencyLabels(s, :) = info.freqLabels';                
            catch err
                rcaExtra_displayError(err)
                display(['Warning, could not load data from: ' subjs{s}]);
            end
        end
    end
    
    
    datasetFrequencyLabels = cellfun(@(x) x', datasetFrequencyLabels, 'uni', false);
    tableFileName =  fullfile(sourceData, 'DatasetInfo.xlsx');
    % break into conditions and compile tables
    nConditions = size(datasetBinLabels, 2);
    for nc = 1:nConditions
        tb = table(subjs', datasetBinLabels(:, nc), datasetFrequencyLabels(:, nc), ...
            'VariableNames', {'ID', 'Bins', 'Frequencies'});
        writetable(tb, tableFileName, 'sheet', nc);
    end
end
