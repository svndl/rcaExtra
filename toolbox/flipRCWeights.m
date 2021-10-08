function flipRCWeights(experiment, group, curr_path)

    %% load and plot all weights
    if (isempty(curr_path))
        [whereami, ~, ~] = fileparts(mfilename('fullpath'));  
        curr_path = uigetdir(whereami, 'Select the EEG raw data folder');
    end
    savedResultsDir = fullfile(curr_path, 'EEG_DATA', experiment);
    dataInfo = getExperimentInfo(experiment);
    if (ischar(group))
        nGroups = size(dataInfo.subgroupsLabels, 2);
        groupLabels = dataInfo.subgroupsLabels;
        cndLabels = dataInfo.subcndLabels;
    else
        nGroups = numel(group);
        groupLabels = group;
        cndLabels = dataInfo.subcndLabels;        
    end
    nConditions = size(dataInfo.subcndLabels, 2);    
    tc = linspace(0, 1000/dataInfo.frequency, 420/dataInfo.frequency);
    for c = 1:nConditions
        fileRCA_cnd = fullfile(savedResultsDir, group, 'results', ['RCA_' cndLabels{c} '.mat']);
        fprintf('Loading ...%s\n', cndLabels{c}); 
        try
            flipWeights(fileRCA_cnd, tc);
        catch
            disp([ 'No file at ' fileRCA_cnd]);
        end
    end
    
    for g = 1:nGroups   
        fprintf('Loading ...%s\n', groupLabels{g});
        fileRCA_group = fullfile(savedResultsDir, group, 'results', ['RCA_' groupLabels{g} '.mat']); 
        try
            flipWeights(fileRCA_group, tc);
        catch
            disp([ 'No file at ' fileRCA_group]);
        end
        for c = 1:nConditions
            fileRCA_groupcnd = fullfile(savedResultsDir, group, 'results', ['RCA_' strcat(groupLabels{g}, cndLabels{c}) '.mat']);
            fprintf('Loading ...%s\n', strcat(groupLabels{g}, cndLabels{c}));
            try
                flipWeights(fileRCA_groupcnd, tc);
            catch
                disp([ 'No file at ' fileRCA_groupcnd]);
            end
        end      
    end
end
