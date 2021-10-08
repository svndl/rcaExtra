function f = rcaExtra_barplot_stats_freq(frequencies, vals, errs, colors, labels, pValues)
       
    % number of harmonics/conditions to display    
    [nF, nInst] = size(vals);    
    
    % labels for x-axis
    xlabels = arrayfun( @(x) strcat(num2str(x), 'Hz'), frequencies, 'uni', false);
       
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
    
    beh = errorbar(xE, vals, errLow, errHigh, 'LineStyle', 'none'); hold on;        
    
    patchSaturation = 0.15;
    
    % plotting bars
    for ni = 1:nInst
        cndColor = colors(:, ni);        
        patchColor = cndColor + (1 - cndColor)*(1 - patchSaturation);        
        
        % define  
        errorBarSettings = {...
            'Color', cndColor, ...
            'LineWidth', 2, ...
            'LineStyle', 'none'};

        
        barSettings = {...        
            'LineWidth', 2, ...
            'EdgeColor', cndColor, ...
            'FaceColor', patchColor};
        
        % define significant/ non significant colors         
        bar(xE(:, ni), vals(:, ni), 0.8*groupWidth/nInst, barSettings{:}); hold on;
        errorbar(xE(:, ni), vals(:, ni), errLow(:, ni), errHigh(:, ni), errorBarSettings{:}); hold on;        
        
        set(beh(ni), errorBarSettings{:});                
    end    
    legendHandle = beh;
    % axis consmetics
    try
        set(gca, 'XTick', 1:numel(frequencies))
        set(gca, 'XTickLabel', xlabels);
    catch
        xlabel(xlabels);
    end
    if (~isempty(labels))
        legend(legendHandle, labels{:}, 'Interpreter', 'none',  'FontSize', 30, 'EdgeColor', 'none', 'Color', 'none');
    end
    currYLimit = ylim(gca);
    ylim([0, 1.2*currYLimit(2)]);
    title('Amplitude Values');
    set(gca,'FontSize', 30, 'fontname', 'helvetica', 'FontAngle', 'italic');
    ylabel('Amplitude (\muV)');
    pbaspect(gca, [1 1 1]);
    
    if (~isempty(pValues))
        ax = get(f, 'CurrentAxes');
        plot_addStatsBar_freq(ax, pValues, vals);        
    end  
end