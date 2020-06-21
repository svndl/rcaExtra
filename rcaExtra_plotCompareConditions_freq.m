function [fh_AmplitudesFreqs, fh_Lolliplots]= rcaExtra_plotCompareConditions_freq(plotSettings, rcaData)
% compares conditions within group

%% INPUT:
    % groupData is a structure with following elements: 
    % groupData.amp = values amp, 
    % groupData.phase = values phase, 
    % groupData.EllipseError = error ellipses
    % groupData.stats -- values for statistical info (computed between conditions and between groups)
    % groupData.A -- topography
    % groupData.label -- group label
    close all;
    nCnd = size(rcaData.projAvg.amp, 3);
    
    if (isempty(plotSettings))  
        plotInfo = getOnOffPlotSettings('groups', 'Frequency');         
        % two figures per component
        nComp = rcaData.rcaSettings.nComp;
    else
        plotInfo = getOnOffPlotSettings('groups', 'Frequency');                 
        plotInfo.legendLabels = plotSettings.conditionLabels;
        nComp = plotSettings.RCsToPlot;
        plotInfo.Title = plotSettings.groupLabel;
        plotInfo.colorOrder = 1;     %will pick first row   
        plotInfo.Marker = 'o';
        if(isfield(plotSettings, 'colorScheme'))
           plotInfo.colors =  plotSettings.colorScheme;
        end  
    end

    nFreqs = numel(rcaData.rcaSettings.freqsToUse);
    % for latency estimate
    freqHZ = rcaData.rcaSettings.freqsUsed;
    
    fh_AmplitudesFreqs = cell(nComp, 1);
    fh_Lolliplots = cell(nComp, 1);
   
    % specify number of subplots for amplitude and frequency
    nSubplots_Row = 1;    
    nSubplots_Col = 2;
    
    % stat template
    asterisk = repmat('*', nFreqs, 1) ;
    asterick_plotSettings = {'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
                'FontSize', 50, 'fontname', 'helvetica'};
    
    for cp = 1:nComp
        % plotting amplitude/latency 
        fh_AmplitudesFreqs{cp} = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
        fh_AmplitudesFreqs{cp}.Name = strcat(plotInfo.Title, num2str(cp));
        %  
        amplitudes = subplot(nSubplots_Row, nSubplots_Col, 1, 'Parent', fh_AmplitudesFreqs{cp});
        latencies = subplot(nSubplots_Row, nSubplots_Col, 2, 'Parent', fh_AmplitudesFreqs{cp});
    
        %% concat bars for amplitude plot
        groupAmps = squeeze(rcaData.projAvg.amp(:, cp, :));
        groupAmpErrs = squeeze(rcaData.projAvg.errA(:, cp, :, :));
        freqplotBar(amplitudes, groupAmps, groupAmpErrs, plotInfo.colors, plotInfo.legendLabels);
        set(amplitudes, plotInfo.axesprops{:});
        pbaspect(amplitudes, [1 1 1]);
        
        % if number of conditions is 2 or 1, add significance
        if(nCnd <= 2) 
        
            %% add stats
            statSettings = rcaExtra_getStatsSettings(rcaData.rcaSettings);
            subjRCMean = rcaExtra_prepareDataArrayForStats(rcaData.projectedData', statSettings);        
            statData = rcaExtra_testSignificance(subjRCMean, [], statSettings);
               
             % pValues text Y position
            currRC_sig = statData.sig(:, cp);
            currRC_pV = statData.pValues(:, cp);
            text_maxY = 0.5*max(groupAmps, [], 2);
            text_sigAsterick = asterisk(currRC_sig > 0);
        
            text(amplitudes, 1:length(currRC_pV), ...
                text_maxY, num2str(currRC_pV,'%0.3f'), plotInfo.statssettings{:});
        
            text(amplitudes, find(currRC_sig>0), ...
                groupAmps(currRC_sig > 0), text_sigAsterick, asterick_plotSettings{:});
               
        end
        %% concat frequency for latency plot
        groupAngles = unwrapPhases(squeeze(rcaData.projAvg.phase(:, cp, :)));
        groupAnglesErrs = squeeze(rcaData.projAvg.errP(:, cp, :, :));
        freqPlotLatency(latencies, groupAngles, groupAnglesErrs, plotInfo.colors, plotInfo.legendLabels, freqHZ);
        set(latencies, plotInfo.axesprops{:});
        pbaspect(latencies, [1 1 1]);
        %% save amp-frequency 
        fig_file = fullfile(rcaData.rcaSettings.destDataDir_FIG, ['rcaExtra_plotConditions_AmpFreq_RC_' num2str(cp)]);
        saveas(fh_AmplitudesFreqs{cp}, fig_file, 'png');
        saveas(fh_AmplitudesFreqs{cp}, fig_file, 'fig');
        
        
        %% lolliplots
        fh_Lolliplots{cp} = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
        fh_Lolliplots{cp}.Name =  strcat(plotInfo.Title, '_Lolliplots RC', num2str(cp));
        for nf = 1:nFreqs 
            ax{nf} = subplot(nSubplots_Row, nFreqs, nf, 'Parent', fh_Lolliplots{cp});
            axes(ax{nf}); 
        
            for nc = 1:nCnd
                colorGroup = plotInfo.colors(nc, :);            
                groupstyle = plotInfo.linestyles{nc};

                alpha = groupAngles(nf, nc);
                L = groupAmps(nf, nc);
                try
                    ellipseCalc = rcaData.projAvg.ellipseErr{nc};
                catch
                    ellipseCalc = rcaData.projAvg{nc}.err;
                end
                x = L.*cos(alpha);
                y = L.*sin(alpha);
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
                props = { 'linewidth', 8, 'color', colorGroup, 'linestyle', groupstyle};             
                patchSaturation = 0.5;
                patchColor =  colorGroup + (1 - colorGroup)*(1 - patchSaturation);
                errLine = line(e_x, e_y, 'LineWidth', 5); hold on;
                set(errLine,'color', patchColor);
                legendRef{nc} = plot(ax{nf}, [0, x], [0, y], props{:}); hold on;
            end
            set(ax{nf}, plotInfo.axesprops{:});
            setAxisAtTheOrigin(ax{nf});

            %descr = ['Conditions ' freqLabels{nf}];
            legend([legendRef{:}], plotInfo.legendLabels(:));
            %title(plotInfo.Title, 'Interpreter', 'none');
        end
        %linkaxes([ax{:}],'xy');
        %setAxisAtTheOrigin(ax);
        %% save lolliplot
        fig_file = fullfile(rcaData.rcaSettings.destDataDir_FIG, ['rcaExtra_plotConditions_Lolliplots_RC_' num2str(cp)]);
        saveas(fh_Lolliplots{cp}, fig_file, 'png');
        saveas(fh_Lolliplots{cp}, fig_file, 'fig');        
     end
end

