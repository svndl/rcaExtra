function rcaExtra_plotSignificantResults_freq(rcaResult1, rcaResult2, statData, plotSettings)
    if (isempty(plotSettings))
       % fill settings template
       plotSettings = rcaExtra_getPlotSettings(rcaResult1.rcaSettings);
       plotSettings.legendLabels = arrayfun(@(x) strcat('Condition ', num2str(x)), ...
           1:size(rcaResult1.projectedData, 1), 'uni', false);
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
    hasSecondDataset = ~isempty(rcaResult2);
    rcResult1_avg = rcaExtra_computeAverages(rcaResult1);    
    nConditions = size(rcResult1_avg.projAvg.amp, 3);
    rcaResultGroups = {rcResult1_avg};
    
    % if second dataset is present, use rcaExtraCompareGroups code 
    if (hasSecondDataset)
        rcResult2_avg = rcaExtra_computeAverages(rcaResult2);
        rcaResultGroups = {rcResult1_avg, rcResult2_avg};
    end
    freqIdx = cellfun(@(x) str2double(x(1)), rcaResult1.rcaSettings.useFrequencies, 'uni', true);
    freqVals = rcaResult1.rcaSettings.useFrequenciesHz*freqIdx;
    freqLabels = arrayfun( @(x) strcat(num2str(x), 'Hz'), freqVals, 'uni', false);

    prevAxHandleAmp = [];
    prevAxHandleLat = [];

    % loop over conditions first (for second )
    for nc = 1:nConditions
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
        
        plotSettings_cnd = plotSettings;
        plotSettings_cnd.useColors = plotSettings.colors.interleaved(:, :, nc);
        
        % next loop over components and plot conditions (combined) individually 
        for cp = 1:numel(plotSettings.RCsToPlot)
        
            rc = plotSettings.RCsToPlot(cp);
            
            % significant frequencies for condition-component
            significance_RC = statData.sig(:, rc, nc);
            
            significantIdx = freqIdx(significance_RC > 0);
            significantFreqs = freqVals(significantIdx);
            pValues = statData.pValues(significantIdx, rc, nc);
              
            % select significant values from amplitude/phase and 
            lats = rcaResultCondition_template.projAvg.phase(significantIdx, rc);
            latErrs = rcaResultCondition_template.projAvg.errP(significantIdx, rc, :, :);

            amps = rcaResultCondition_template.projAvg.amp(significantIdx, rc);
            ampErrs = rcaResultCondition_template.projAvg.errA(significantIdx, rc, :, :);

            % plot latencies with significance
            latPlot_rc_Cnd = rcaExtra_latplot_freq(significantFreqs, lats, latErrs, ...
                plotSettings_cnd.useColors(), plotSettings_cnd.legendLabels);
            
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
            % plot amplitudes with significance
            ampPlot_rc_Cnd = rcaExtra_barplot_freq(significantFreqs, amps, ampErrs,...
               plotSettings_cnd.useColors(), plotSettings_cnd.legendLabels);      
           
            ampAxes = get(ampPlot_rc_Cnd, 'CurrentAxes');
            ampAxes.Title.String = strcat('Amplitude RC:', num2str(rc),' Cnd: ', num2str(nc));
            
            % add back labels
            if (numel(ampAxes.XTick) < numel(freqIdx))
                ampAxes.XTick = freqIdx;
                ampAxes.XTickLabel = freqLabels'; 
            end
            % add significance
            asterisk_1 = repmat({'*'}, size(amps, 1), 1);
            asterisk_2 = repmat({'**'}, size(amps, 1), 1);
            asterisk_3 = repmat({'***'}, size(amps, 1), 1);
           
            asterick_plotSettings = {'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
                'FontSize', 50, 'fontname', 'helvetica', 'Color', 'r'};
            
            %currRC_sig = statData.sig(:, c);
            currRC_sig_1 = (pValues < 0.05).* (pValues > 0.01);
            currRC_sig_2 = (pValues < 0.01).*(pValues > 0.001);
            currRC_sig_3 = pValues < 0.001;
            
            % pValues text Y position
            text_maxY = 0.35*amps ;
            
            text_sigAsterick_1 = asterisk_1(currRC_sig_1 > 0);
            text_sigAsterick_2 = asterisk_2(currRC_sig_2 > 0);
            text_sigAsterick_3 = asterisk_3(currRC_sig_3 > 0);
            
            % display pValue (should be optional)
            text(ampAxes, 1:length(pValues), ...
                text_maxY, num2str(pValues, '%0.4f'), 'FontSize', 20);
            
            % display significance 
            text(ampAxes, find(currRC_sig_1 > 0), ...
                amps(currRC_sig_1 > 0), text_sigAsterick_1, asterick_plotSettings{:});
            
            text(ampAxes, find(currRC_sig_2 > 0), ...
                amps(currRC_sig_2 > 0), text_sigAsterick_2, asterick_plotSettings{:});
            
            text(ampAxes, find(currRC_sig_3 > 0), ...
                amps(currRC_sig_3 > 0), text_sigAsterick_3, asterick_plotSettings{:});
                            
            % add pValue legends
            text(ampAxes, numel(freqIdx), amps(1), '* : 0.01 < p < 0.05', ...
                'FontSize', 20, 'fontname', 'helvetica', 'Color', 'k');        
            text(ampAxes,  numel(freqIdx), 0.9*amps(1), '** : 0.001 < p < 0.01', ...
                'FontSize', 20, 'fontname', 'helvetica', 'Color', 'k');
            text(ampAxes,  numel(freqIdx), 0.7*amps(1), '*** : p < 0.001', ...
                'FontSize', 20, 'fontname', 'helvetica', 'Color', 'k');
            
            % rename and save
            ampPlot_rc_Cnd.Name = strcat('RC ', num2str(rc), 'Cnd ', num2str(nc), ...
                ' F = ', num2str(rcaResult1.rcaSettings.useFrequenciesHz));
           
           
            %% save figure in rcaResult.rcaSettings
            try
                saveas(latPlot_rc_Cnd, ...
                    fullfile(rcaResult1.rcaSettings.destDataDir_FIG, [latPlot_rc_Cnd.Name '.fig']));
                saveas(ampPlot_rc_Cnd, ...
                    fullfile(rcaResult1.rcaSettings.destDataDir_FIG, [ampPlot_rc_Cnd.Name '.fig']));             
            catch err
                rcaExtra_displayError(err);
            end
            if (~isempty(prevAxHandleAmp))
                linkaxes([prevAxHandleAmp, ampAxes], 'xy'); 
            end
            if (~isempty(prevAxHandleLat))
                linkaxes([prevAxHandleLat, latAxes], 'xy'); 
            end
            
            prevAxHandleAmp = ampAxes; 
            prevAxHandleLat = latAxes;
        end
    end
end