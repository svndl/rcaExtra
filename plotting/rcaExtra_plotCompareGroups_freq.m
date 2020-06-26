function rcaExtra_plotCompareGroups_freq(plotSettings, varargin)

%% INPUT:
    % groupData is a structure with following elements: 
    % groupData.amp = values amp, 
    % groupData.phase = values phase, 
    % groupData.EllipseError = error ellipses
    % groupData.stats -- values for statistical info (computed between conditions and between groups)
    % groupData.A -- topography
    % groupData.label -- group label
    
      
    nGroups = nargin - 1;
    groupRCAData = varargin;
    
    %% groups must have comparable number of frequencies and RC components
    
    nRCs = cell2mat(cellfun(@(x) getfield(x, 'rcaSettings', 'nComp'), groupRCAData, 'uni', false));
    nCnds = cell2mat(cellfun(@(x) size(getfield(x, 'projAvg', 'amp'), 3), groupRCAData, 'uni', false));
    nFreqs = cell2mat(cellfun(@(x) numel(getfield(x, 'rcaSettings', 'freqsToUse')), groupRCAData, 'uni', false));
    freqHZ = unique(cell2mat(cellfun(@(x) getfield(x, 'rcaSettings', 'freqsUsed'), groupRCAData, 'uni', false)));

    % Minimum common number of things to plot
    rcsToPLot = min(nRCs);
    freqsToPlot = 1:min(nFreqs);
    cndsToPlot = min(nCnds);
    
    if (numel(freqHZ) > 1)
        % more than 1 frequency, latency plots won't be vaild
        % todo maybe don't plot latency
        %
        disp(['WARNING: Frequencies don''t match' num2str(freqHZ)]);
    end
    
    if (isempty(plotSettings))  
        plotInfo = getOnOffPlotSettings('grayscale', 'Frequency');         
        % two figures per component
    else
        plotInfo = getOnOffPlotSettings('grayscale', 'Frequency');                 
        plotInfo.legendLabels = plotSettings.conditionLabels;
        rcsToPLot = plotSettings.RCsToPlot;
        plotInfo.Title = plotSettings.groupLabel;
        if(isfield(plotSettings, 'colorScheme'))
           plotInfo.colors =  plotSettings.colorScheme;
        end  
    end
    
    % amplitude and frequency allocation/setup
    
    fh_AmplitudesFreqs = cell(rcsToPLot, 1);
    fh_Lolliplots = cell(rcsToPLot, 1);
   
    % specify number of subplots for amplitude and frequency
    nSubplots_Row = 1;    
    nSubplots_Col = 2;
    
    % stat template
    asterisk = repmat('*', nFreqs, 1) ;
    asterick_plotSettings = {'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
                'FontSize', 50, 'fontname', 'helvetica'};
            
    for cp = 1:rcsToPLot
        for nc = 1:cndsToPlot
            % plotting amplitude/latency 
            fh_AmplitudesFreqs{cp} = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
            fh_AmplitudesFreqs{cp}.Name = strcat('Comparing Groups', plotInfo.legendLabels{nc}, 'RC ', num2str(cp));
            %  
            amplitudes = subplot(nSubplots_Row, nSubplots_Col, 1, 'Parent', fh_AmplitudesFreqs{cp});
            latencies = subplot(nSubplots_Row, nSubplots_Col, 2, 'Parent', fh_AmplitudesFreqs{cp});
    
            %% concat bars for amplitude plot
            groupAmp_cell = cellfun(@(x) squeeze(x.projAvg.amp(:, cp, nc)), groupRCAData, 'uni', false);
            groupAmpErrs_cell = cellfun(@(x) squeeze(x.projAvg.errA(:, cp, nc, :)), groupRCAData, 'uni', false);
        
            groupAmp = cat(2, groupAmp_cell{:});
            groupAmpErrs = cat(3, groupAmpErrs_cell{:});
            % plot all bars first
            freqplotBar(amplitudes, groupAmp, permute(groupAmpErrs, [1 3 2]), plotInfo.colors(:, :, nc), plotSettings.groupLabel);
        
            set(amplitudes, plotInfo.axesprops{:});
            pbaspect(amplitudes, [1 1 1]);
        
                % if number of conditions is 2 or 1, add significance
            if(nGroups == 2) 
        
                %% add stats
                statSettings1 = rcaExtra_getStatsSettings(groupRCAData{1}.rcaSettings);
                statSettings2 = rcaExtra_getStatsSettings(groupRCAData{2}.rcaSettings);
            
                subjRCMean1 = rcaExtra_prepareDataArrayForStats(groupRCAData{1}.projectedData(nc, :)', statSettings1);
                subjRCMean2 = rcaExtra_prepareDataArrayForStats(groupRCAData{2}.projectedData(nc, :)', statSettings2);        
            
                statData = rcaExtra_testSignificance(subjRCMean1, subjRCMean2, statSettings1);
               
                % pValues text Y position
                currRC_sig = statData.sig(:, cp);
                currRC_pV = statData.pValues(:, cp);
                text_maxY = 0.5*max(groupAmp, [], 2);
                text_sigAsterick = asterisk(currRC_sig > 0);
        
                text(amplitudes, 1:length(currRC_pV), ...
                    text_maxY, num2str(currRC_pV,'%0.3f'), plotInfo.statssettings{:});
        
                text(amplitudes, find(currRC_sig>0), ...
                    groupAmp(currRC_sig > 0), text_sigAsterick, asterick_plotSettings{:});
               
            end
            %% Latency plots
            groupLat_cell = cellfun(@(x) squeeze(x.projAvg.phase(:, cp, nc)), groupRCAData, 'uni', false);
            groupLatErrs_cell = cellfun(@(x) squeeze(x.projAvg.errP(:, cp, nc, :)), groupRCAData, 'uni', false);
            groupAngles_raw = cat(2, groupLat_cell{:});
            groupAngles = unwrapPhases(groupAngles_raw);       
            groupAnglesErrs = cat(3, groupLatErrs_cell{:});      
            freqPlotLatency(latencies, groupAngles, permute(groupAnglesErrs, [1 3 2]), plotInfo.colors(:, :, nc), plotSettings.groupLabel, freqHZ);
            set(latencies, plotInfo.axesprops{:});
            pbaspect(latencies, [1 1 1]);
        
            %% save figure 1
            fig_file = fullfile(groupRCAData{1}.rcaSettings.destDataDir_FIG, ['rcaExtra_plotGroups_AmpFreq_' plotInfo.legendLabels{nc} '_RC' num2str(cp)]);
            saveas(fh_AmplitudesFreqs{cp}, fig_file, 'png');
            saveas(fh_AmplitudesFreqs{cp}, fig_file, 'fig');
        
            %% lolliplots
            fh_Lolliplots{cp} = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
            fh_Lolliplots{cp}.Name =  strcat('Lolliplots RC', num2str(cp));
        
            for nf = 1:numel(freqsToPlot)
                for ng = 1:nGroups
                    ax{nf} = subplot(nSubplots_Row, numel(freqsToPlot), nf, 'Parent', fh_Lolliplots{cp});
                    axes(ax{nf});
            
                    colorGroup = plotInfo.colors(ng, :, nc);
                    groupstyle = plotInfo.linestyles{nc};
            
                    alpha = groupAngles(nf, ng);
                    L = groupAmp(nf, ng);
                    try
                        ellipseCalc = groupRCAData{ng}.projAvg.ellipseErr{nc};
                    catch
                        ellipseCalc = groupRCAData{ng}.projAvg{nc}.err;
                    end
                    x = -L.*cos(alpha);
                    y = -L.*sin(alpha);
                    e_x = 0;
                    e_y = 0;
                    try
                        e0 = ellipseCalc{nf, cp};
                    catch
                        e0 = ellipseCalc(nf);
                    end
                    if (~isempty(e0))
                        e_x = e0(:, 1) + x;
                        e_y = e0(:, 2) + y;
                    end
                    props = { 'linewidth', 8, 'color', colorGroup, 'linestyle', ...
                        groupstyle};
                    patchSaturation = 0.5;
                    patchColor =  colorGroup + (1 - colorGroup)*(1 - patchSaturation);
                    errLine = line(e_x, e_y, 'LineWidth', 5); hold on;
                    set(errLine,'color', patchColor);
                    legendRef{ng} = plot(ax{nf}, [0, x], [0, y], props{:}); hold on;
                    set(ax{nf}, plotInfo.axesprops{:});
                    setAxisAtTheOrigin(ax{nf});
        
                    %descr = ['Conditions ' freqLabels{nf}];
                    legend([legendRef{:}], plotInfo.Title(:));
                %title(descr, 'Interpreter', 'none');
                end
            end
            %linkaxes([ax{:}],'xy');
            %setAxisAtTheOrigin(ax);
            fig_file = fullfile(groupRCAData{1}.rcaSettings.destDataDir_FIG, ['rcaExtra_plotGroups_Lolli_' plotInfo.legendLabels{nc} '_RC' num2str(cp)]);
            saveas(fh_Lolliplots{cp}, fig_file, 'png');
            saveas(fh_Lolliplots{cp}, fig_file, 'fig');     
        end
    end    
end

