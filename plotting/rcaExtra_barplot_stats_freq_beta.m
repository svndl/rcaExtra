function f = rcaExtra_barplot_stats_freq_beta(inData, rc, statData, plotSettings)            
    % select condition per component
    vals = squeeze(inData.amp(:, rc, :));
    errs = squeeze(inData.errP(:, rc, :, :));
        
    % number of harmonics/conditions to display    
    [nF, nInst] = size(vals);    
    
    % labels for x-axis
    xlabels = arrayfun( @(x) strcat(num2str(x), 'Hz'), inData.frequencies, 'uni', false);
       
    % adjusting bar width according to number of conditions
    groupWidth = min(0.8, nInst/(nInst + 1.5));
    xE = zeros(nF, nInst);
    
    % xE will indicate position and width of the bars 
    for b = 1:nInst
        xE(:, b) = (1:nF) - groupWidth/2 + (2*b -1 )*groupWidth / (2*nInst);
    end
    
    % create figure
    f = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    set(gcf, 'renderer', 'openGL');
    
    % plotting errors first and saving plot handles for the legends 
    if (nInst > 1)
        errLow = squeeze(errs(:, :, 1));
        errHigh = squeeze(errs(:, :, 2));
    end
    if (nInst == 1)
        errLow = squeeze(errs(:, 1));
        errHigh = squeeze(errs(:, 2));        
    end
    legendHandle = errorbar(xE, vals, errLow, errHigh); hold on;
    
    % plotting bars
    for ni = 1:nInst
        cndColor = plotSettings.useColors(:, ni);        
        patchColor = cndColor + (1 - cndColor)*(1 - plotSettings.patchSaturation);        
        
        % define  
        errorBarSettings = {...
            'Color', cndColor, ...
            'LineStyle', plotSettings.ampPlotSettings.errorBarProps.LineStyle, ...
            'LineWidth', plotSettings.ampPlotSettings.errorBarProps.LineWidth, ...
            'CapSize', plotSettings.ampPlotSettings.errorBarProps.CapSize, ...
            'Marker', plotSettings.ampPlotSettings.errorBarProps.Marker, ...
            'MarkerSize', plotSettings.ampPlotSettings.errorBarProps.MarkerSize, ...
            'MarkerEdgeColor', plotSettings.ampPlotSettings.errorBarProps.MarkerEdgeColor, ...
            'MarkerFaceColor', plotSettings.ampPlotSettings.errorBarProps.MarkerFaceColor};
        
        barSettings = {...        
            'LineStyle', plotSettings.ampPlotSettings.barProps.LineStyle, ...
            'LineWidth', plotSettings.ampPlotSettings.barProps.LineWidth, ...
            'EdgeColor', cndColor, ...
            'FaceColor', patchColor};
        
        % define significant/ non significant colors
          
        bar(xE(:, ni), vals(:, ni), 0.8*groupWidth/nInst, barSettings{:}); hold on; 
        beh = errorbar(xE, vals, errLow, errHigh); hold on;        
        set(beh(ni), errorBarSettings{:});             
                
    end    
    
    % axis consmetics
    try
        set(gca, 'XTick', 1:numel(frequencies))
        set(gca, 'XTickLabel', xlabels);
    catch
        xlabel(xlabels);
    end
    if (~isempty(plotSettings.labels))
        legend(legendHandle, plotSettings.labels{:}, 'Interpreter', 'none',  'FontSize', 30, 'EdgeColor', 'none', 'Color', 'none');
    end
    currYLimit = ylim(gca);
    ylim([0, 1.2*currYLimit(2)]);
    title('Amplitude Values');
    set(gca,'FontSize', 30, 'fontname', 'helvetica', 'FontAngle', 'italic');
    ylabel('Amplitude (\muV)');
    pbaspect(gca, [1 1 1]);
    
    if (~isempty(statData))
        pValues = squeeze(statData.pValues(:, rc, :));        
        plot_addStatsBar_freq(gca, pValues, vals)          
    end  
end
