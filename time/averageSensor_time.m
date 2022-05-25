function sensorResult = averageSensor_time(currSettings, dataIn)
    % resample data if needed
    resampled_data = dataIn;
    if (size(dataIn{1, 1}, 1) ~= currSettings.cycleLength)
        resampled_data = resampleData(dataIn, currSettings.cycleLength);
    end
    if (~isempty(currSettings.useCnds))
        dataSlice = resampled_data(:, currSettings.useCnds);
    else
        dataSlice = resampled_data;
    end

    subjMean_cell = cellfun(@(x) nanmean(x, 3), dataSlice', 'uni', false)';
    nCnd = size(subjMean_cell, 2);
    subjMean_bycnd = cell(1, nCnd);
    for nc = 1:nCnd
         cndData = cat(3, subjMean_cell{:, nc});
         % baseline
         subjMean_bycnd{nc} = cndData - repmat(cndData(1, :, :), [size(cndData, 1) 1 1]);
    end
        
    % for joint projection, compute mean/std
    subjMean = squeeze(cat(3, subjMean_bycnd{:}));    
    sensorResult.mu = nanmean(subjMean, 3);
    sensorResult.s = nanstd(subjMean, [], 3)/(sqrt(size(subjMean, 3)));
    
    % for each condition, compute individual mean/std
    mu_cnd = cellfun(@(x) nanmean(x, 3), subjMean_bycnd, 'uni', false);
    s_cnd = cellfun(@(x) nanstd(x, [], 3)/(sqrt(size(x, 3))), subjMean_bycnd, 'uni', false);
    sensorResult.mu_cnd = cat(3, mu_cnd{:});
    sensorResult.s_cnd = cat(3, s_cnd{:});
    
    
    tc = linspace(0, currSettings.cycleDuration - 1, currSettings.cycleLength);
    sensorResult.timecourse = tc;
    sensorResult.rcaSettings = currSettings;
    sensorResult.projectedData = dataIn;
end