function [sensorData, settings] = reshapeRawData(experiment, groupLabels, subtype)

    % function loads and groups _subtype_ (axx, raw, freq) data from _experiment_/_groupLabels_ 
    % 
    [curr_path, ~, ~] = fileparts(mfilename('fullpath'));
    
    if (isempty(subtype))
            subtype = 'raw';         
    end
    %% specify design
    savedAnalysisDir = fullfile(curr_path, 'EEG_DATA', experiment);
    if (~exist(savedAnalysisDir, 'dir'))
        mkdir(savedAnalysisDir);
    end
    ngroups = size(groupLabels, 2);
    avgData = cell(1, ngroups);
    group_rawData = cell(ngroups, 1);
    
    % get experiment info with subgroups/frequencies
    
    dataInfo = getExperimentInfo(experiment);
    nCnds = size(dataInfo.conditionLabels, 2);
    
    for ng = 1:ngroups
        disp(['Loading ' experiment ': ' groupLabels{ng} ':' subtype])
        dataStruct_curr = ragu_getData(experiment, groupLabels{ng}, 0, subtype);
        nSubjs = size(dataStruct_curr.rawData, 1);
        avgDataG = cellfun(@(x) nanmean(x, 3), dataStruct_curr.rawData, 'uni', false);
        combinedData = cat(3, avgDataG{:});
        nSamples = size(combinedData, 1);
        nChannels = size(combinedData, 2);
        reshapedData = reshape(combinedData, nSamples, nChannels, nSubjs, nCnds);
        avgData{ng}  = permute(reshapedData, [3 4 2 1]);
        group_rawData{ng} = dataStruct_curr.rawData;
    end
    % groups are conditions
    % go from 1 cell of nSubj x nCond x nCh x nSamples to
    % nCond/2 cells of nSubj x 2 x nCh x nSamples
    settings.freq = dataInfo.frequency;
    if (ngroups == 1)
        numSubGroups = numel(dataInfo.subgroupsLabels);
        reshapedCellData =  cell(numSubGroups, 1);
        for sg = 1:numSubGroups
            reshapedCellData{sg} = group_rawData{ng}(:, dataStruct_curr.(['group' num2str(sg)]));
        end
        groupData = conditionsToGroups(avgData, 2);
        if (numel(dataInfo.subgroupsLabels) > 1)
            settings.groupLabels = [dataInfo.subgroupsLabels];
        else
            settings.groupLabels = [groupLabels dataInfo.subgroupsLabels];
        end
        settings.conditionLabels = dataInfo.subcndLabels;
    else
        reshapedCellData = group_rawData;
        groupData = avgData;
        settings.groupLabels = groupLabels;
        settings.conditionLabels = dataInfo.conditionLabels;
    end
    
    sensorData.eegGrouped = groupData';
    sensorData.rawData = reshapedCellData;
end