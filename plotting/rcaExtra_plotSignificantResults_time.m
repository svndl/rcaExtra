function rcaExtra_plotSignificantResults_time(rcaResult1, rcaResult2, statData, plotSettings)

% create default plot settings
% 
    if (isempty(plotSettings))
       % fill settings template
       plotSettings = rcaExtra_getPlotSettings(rcaResult1);       
       plotSettings.Title = 'Waveforms';
       plotSettings.RCsToPlot = 1:3;
    end

    % compute average waveforms for each structure

    % create template structure from first rcRresult input 
    rcaResultCondition_template = rcaResult1;
    
    hasSecondDataset = ~isempty(rcaResult2);
    rcResult1_avg = rcaExtra_computeAverages(rcaResult1);    
    rcaResultGroups = {rcResult1_avg};
    
    % if second dataset is present, use rcaExtraCompareGroups code 
    if (hasSecondDataset)
        rcResult2_avg = rcaExtra_computeAverages(rcaResult2);
        rcaResultGroups = {rcResult1_avg, rcResult2_avg};
        
        % change to Group labels
        plotSettings.legendLabels = arrayfun(@(x) strcat('Group ', num2str(x)), ...
           1:2, 'uni', false);     
    end
    
    % number of conditions per group
    nCndsPerGroup = cellfun(@(x) size(x.projectedData, 2), rcaResultGroups, 'uni', true);
    nCnd = unique(nCndsPerGroup);
    
    % if number of conditions varies, loop over minimum
    if (nCnd > 1)
        nCnd = min(nCnd);
    end
    
    % check timecourse duration for each group and use minimum (shortest)
    % in case it varies across groups
    
    nSamplesPerGroup = cellfun(@(x) size(x.timecourse, 2), rcaResultGroups, 'uni', true);
    durationPerGroup = cellfun(@(x) x.timecourse(end), rcaResultGroups, 'uni', true);
    nSamples = min(nSamplesPerGroup);
    rcaResultCondition_template.timecourse = linspace(0, min(durationPerGroup), nSamples);
    
    % fields that will be merged together by condition:
    % rcaResultCondition_template.mu_cnd
    % rcaResultCondition_template.s_cnd
    
    prevAxHandle = [];
    for nc = 1:nCnd
        %merge group data by condition
        groupsMu = cellfun(@(x) x.mu_cnd(:, :, nc), rcaResultGroups, 'uni', false);
        groupsStd = cellfun(@(x) x.s_cnd(:, :, nc), rcaResultGroups, 'uni', false);
        
        % combine all 
        rcaResultCondition_template.mu_cnd = cat(3, groupsMu{:});
        rcaResultCondition_template.s_cnd = cat(3, groupsStd{:});
          
        plotSettings_cnd = plotSettings;
        plotSettings_cnd.useColors = squeeze(plotSettings.colors.interleaved(nc, :, :));
        
        
        % create groups+condition labels for legends
        if (~isempty(plotSettings) && ~isempty(plotSettings.legendLabels))
            %plotSettings_cnd.legendLabels = cellfun(@(x) strcat(x, ' ', num2str(nc)))
        end
                
        % call condition plotting
        for cp = 1:numel(plotSettings.RCsToPlot)
            
            rc = plotSettings.RCsToPlot(cp);
            
            fhWaveforms = rcaExtra_plotWaveforms_time(rcaResultCondition_template.timecourse, ...
                squeeze(rcaResultCondition_template.mu_cnd(:, rc, :)),...
                squeeze(rcaResultCondition_template.s_cnd(:, rc, :)), plotSettings.useColors, plotSettings.legendLabels);
            
            % get current axes
            currAxisHandle = get(fhWaveforms, 'CurrentAxes');
            currAxisHandle.Title.String = strcat('Waveforms RC:', num2str(rc),' Cnd: ', num2str(nc));
            % add stats bar
            significance_RC = statData.sig(:, rc, nc);
            pValues = statData.pValues(:, rc, nc);
            
            plot_addStatsBar_time(currAxisHandle, pValues, significance_RC, rcaResultCondition_template.timecourse);
        
            fhWaveforms.Name = strcat('RC ', num2str(rc), plotSettings.Title);
        
            %% save figure in rcaResult.rcaSettings
            try
                saveas(fhWaveforms, ...
                    fullfile(rcaResult1.rcaSettings.destDataDir_FIG, [fhWaveforms.Name '.fig']));
            catch err
                rcaExtra_displayError(err);
            end
            
            % same scale axes
            if (~isempty(prevAxHandle))
                linkaxes([prevAxHandle, currAxisHandle], 'xy'); 
            end
            prevAxHandle = currAxisHandle;
        end      
        % comment plot settings
    end

end