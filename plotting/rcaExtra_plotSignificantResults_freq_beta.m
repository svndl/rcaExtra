function rcaExtra_plotSignificantResults_freq_beta(rcaResult1, rcaResult2, statData, plotSettings)
    hasSecondDataset = ~isempty(rcaResult2);
    nGroups = 1;
    if (isempty(plotSettings))
       % fill settings template
       plotSettings = rcaExtra_getPlotSettings(rcaResult1);
       plotSettings.groupLegends = {'Group 1'};
       plotSettings.useColors = plotSettings.colors.interleaved;       
       
       if (hasSecondDataset)
           plotSettings.groupLegends = {'Group 1', 'Group 2'};  
           nGroups = 2;
       end
       
       
       % default settings for all plotting: 
       % font type, font size
       plotSettings.Title = 'Frequency analysis plots';
       plotSettings.RCsToPlot = 1:3;
       % legend background (transparent)
       % xTicks labels
       % xAxis, yAxis labels
       % hatching (yes/no) 
       % plot title 
        
    end
    rcResult1_avg = rcaExtra_computeAverages(rcaResult1);    
    nConditions = size(rcResult1_avg.projAvg.amp, 3);
    rcaResultGroups = {rcResult1_avg};
    
    % if second dataset is present, use rcaExtraCompareGroups code 
    if (hasSecondDataset)
        rcResult2_avg = rcaExtra_computeAverages(rcaResult2);
        rcaResultGroups = {rcResult1_avg, rcResult2_avg};
    end
    
    % frequency values
    freqIdx = cellfun(@(x) str2double(x(1)), rcaResult1.rcaSettings.useFrequencies, 'uni', true);
    freqVals = rcaResult1.rcaSettings.useFrequenciesHz*freqIdx;
    
    % storing axes handles
    prevAxHandleAmp = [];
    prevAxHandleLat = [];

    % loop over conditions first
    
    for nc = 1:nConditions
        
        % extract condition data from each group
        
        groupsAmp = cellfun(@(x) x.projAvg.amp(:, :, nc), rcaResultGroups, 'uni', false);
        groupsPhase = cellfun(@(x) x.projAvg.phase(:, :, nc), rcaResultGroups, 'uni', false);
        groupsErrA = cellfun(@(x) x.projAvg.errA(:, :, nc, :), rcaResultGroups, 'uni', false);
        groupsErrP = cellfun(@(x) x.projAvg.errP(:, :, nc, :), rcaResultGroups, 'uni', false);
        groupsErrEllipse = cellfun(@(x) x.projAvg.ellipseErr{nc}, rcaResultGroups, 'uni', false);
        
        % combine all 
        rcaResultCondition_template.projAvg.amp = cat(3, groupsAmp{:});
        rcaResultCondition_template.projAvg.phase = cat(3, groupsPhase{:});
        rcaResultCondition_template.projAvg.ellipseErr = groupsErrEllipse';
        
        % error dimentions are nF x nComp x nCnd x 2 
        rcaResultCondition_template.projAvg.errA = cat(3, groupsErrA{:});
        rcaResultCondition_template.projAvg.errP = cat(3, groupsErrP{:});
        
        %plotSettings_cnd = plotSettings;
        useColors = squeeze(plotSettings.useColors(nc, :, :));
        
        legendLabels = cellfun(@(x, y) strcat(x, y), ...
            plotSettings.groupLegends, repmat(plotSettings.legendLabels(nc), [nGroups 1]), 'uni', false);
        
        % next loop over components and plot conditions (combined) individually 
        for cp = 1:numel(plotSettings.RCsToPlot)
        
            rc = plotSettings.RCsToPlot(cp);
                          
            % select significant values from amplitude/phase and 
            lats = squeeze(rcaResultCondition_template.projAvg.phase(:, rc, :));
            latErrs = squeeze(rcaResultCondition_template.projAvg.errP(:, rc, :, :));

            amps = squeeze(rcaResultCondition_template.projAvg.amp(:, rc, :));
            ampErrs = squeeze(rcaResultCondition_template.projAvg.errA(:, rc, :, :));
            
            sigIdx = statData.sig(:, rc, nc) > 0;
            pValues = statData.pValues(:, rc, nc);
            
            %% Plot amplitudes with significance
            try                
                % special barplot 
                ampPlot_rc_Cnd = rcaExtra_barplot_stats_freq(freqVals, ...
                    amps, ampErrs, ...
                    useColors, legendLabels, sigIdx, pValues);
                
                ampAxes = get(ampPlot_rc_Cnd, 'CurrentAxes');
                ampAxes.Title.String = strcat('Amplitude RC:', num2str(rc),' Cnd: ', num2str(nc));
            
                % add back labels
                if (numel(ampAxes.XTick) < numel(freqIdx))
                    ampAxes.XTick = freqIdx;
                    ampAxes.XTickLabel = freqLabels'; 
                end
            
                %% rename and save
                ampPlot_rc_Cnd.Name = strcat('RC ', num2str(rc), 'Cnd ', num2str(nc), ...
                    ' F = ', num2str(rcaResult1.rcaSettings.useFrequenciesHz));
                saveas(ampPlot_rc_Cnd, ...
                    fullfile(rcaResult1.rcaSettings.destDataDir_FIG, [ampPlot_rc_Cnd.Name '_amplitude.fig']));
                
                %% link previous bar chart for uniform yLim scaling 
                if (~isempty(prevAxHandleAmp))
                    linkaxes([prevAxHandleAmp, ampAxes], 'xy'); 
                end
                prevAxHandleAmp = ampAxes; 
                
            catch err
                rcaExtra_displayError(err)
            end
            
            %% plot latencies with significance
            try
                latPlot_rc_Cnd = rcaExtra_latplot_freq_stats(freqVals, lats, latErrs, ...
                    useColors, legendLabels, sigIdx);
            
                latPlot_rc_Cnd.Name = strcat('RC ', num2str(rc),'Cnd ', num2str(nc), ...
                    ' F = ', num2str(rcaResult1.rcaSettings.useFrequenciesHz));
            
                latAxes = get(latPlot_rc_Cnd, 'CurrentAxes');
            
                % update title latencies
                latAxes.Title.String = strcat('Latency RC:', num2str(rc),' Cnd: ', num2str(nc));                      
                % update xLabels
                if (numel(latAxes.XTick) < numel(freqIdx))
                    latAxes.XTick = freqVals;
                    latAxes.XTickLabel = freqLabels; 
                end
                
                %% save latency plots
                saveas(latPlot_rc_Cnd, ...
                    fullfile(rcaResult1.rcaSettings.destDataDir_FIG, [latPlot_rc_Cnd.Name '_latency.fig']));
                
                %% link with previous plot for uniform yLim scaling
                if (~isempty(prevAxHandleLat))
                    linkaxes([prevAxHandleLat, latAxes], 'xy'); 
                end
                prevAxHandleLat = latAxes;
                
            catch err
                rcaExtra_displayError(err)
            end            
        end
    end
end