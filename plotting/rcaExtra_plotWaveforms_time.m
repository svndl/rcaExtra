function figureHandle = rcaExtra_plotWaveforms_time(timeArray, waveformMeans, waveformErrs, colors, labels)

    nConditions = size(waveformMeans, 2);
    
    figureHandle = figure('units', 'normalized', 'outerposition', [0 0 1 1]);

    plotHandles = cell(nConditions, 1);
    for nc = 1:nConditions
        h = shadedErrorBar(timeArray', ...
            waveformMeans(:, nc), waveformErrs(:, nc), {'color', colors(:, nc), 'LineWidth', 2}); hold on;
        plotHandles{nc} = h.mainLine;
    end
    % set legend labels if not empty
    if (~isempty(labels))
        legend([plotHandles{:}], labels, 'Interpreter', 'none', 'FontSize', 30, ...
            'EdgeColor', 'none', 'Color', 'none'); 
    end
        
    % set axes props
    set(gca,'FontSize', 30, 'fontname', 'helvetica', 'FontAngle', 'italic');
    xlabel('Time, (msec)');
    ylabel('Amplitude, (\muV)');
end