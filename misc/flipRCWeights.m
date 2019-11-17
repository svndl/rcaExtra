function flipRCWeights(experiment, group, curr_path)

    %% load and plot all weights
    if (isempty(curr_path))
        [curr_path, ~, ~] = fileparts(mfilename('fullpath'));    
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
function flipWeights(pathRCFile, tc)
    
    load(pathRCFile);
    % display data
    rcaData_old = rcaData;
    A_old = A;
    W_old = W;
    plotRCAResults(rcaData_old, tc, A_old);
    
    % clear the original data
    A = [];
    W = [];
    rcaData = [];
    
    % collect user input
    try
        res = input('Enter weights signs and positions [-1/1, -2/2, -3/3]?\n', 's');
        if (isempty(res))
            return;
        end     
    catch
    end
    
    
    sign_pos = str2num(res);
    
    s0 = sign(sign_pos);
    new_pos = abs(sign_pos);
    new_sign = s0(new_pos);
    
    %% sign
    default_sign = [1 1 1];
    if (~isequal(default_sign, new_sign))    
        s = repmat(new_sign, [128 1]);
        W_sign = W_old.*s;
        A_sign = A_old.*s;
        rcaData_newsign = cellfun(@(x) x.*repmat(new_sign, [size(x, 1) 1 size(x, 3)]), rcaData_old, 'uni', false);
    else
        W_sign = W_old;
        A_sign = A_old;
        rcaData_newsign = rcaData_old;
    end
    plotRCAResults(rcaData_newsign, tc, A_sign);
    
    %% position
    
    default_pos = [1 2 3];
    if (~isequal(new_pos, default_pos))
        W_pos = W_sign(:, new_pos);
        A_pos = A_sign(:, new_pos);
        rcaData_newpos = cellfun(@(x) x(:, new_pos, :), rcaData_newsign, 'uni', false);
    else
        W_pos = W_sign;
        A_pos = A_sign;
        rcaData_newpos = rcaData_newsign;
    end
    
    W = W_pos;
    A = A_pos;
    rcaData = rcaData_newpos;
    
    plotRCAResults(rcaData, tc, A);
    try
        res = input('New waveforms\n', 's');
        if (isempty(res))
        end     
    catch
    end
    try
        save(pathRCFile, 'W', 'A', 'rcaData');
    catch err
        disp('RC file was not updated')
    end
end
